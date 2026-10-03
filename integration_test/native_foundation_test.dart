import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:docket/main_native_acceptance.dart' show NoNetwork;
import 'package:docket/app/app.dart';
import 'package:docket/app/bootstrap.dart';
import 'package:docket/data/local/fixture_repository.dart';
import 'package:docket/platform/connection_native.dart';
import 'package:docket/platform/storage_backend.dart';
import 'package:docket/features/shell/foundation_shell.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native offline foundation, input, resize and measured bulk workload',
    (tester) async {
      HttpOverrides.global = NoNetwork();
      if (Platform.isWindows) {
        final directory = Directory.systemTemp.createTempSync(
          'docket-native-migration-',
        );
        final file = File('${directory.path}/fixture.sqlite');
        final raw = sqlite.sqlite3.open(file.path);
        raw.execute(File('test/fixtures/v1.sql').readAsStringSync());
        raw.close();
        final original = file.readAsBytesSync();
        final migrationBackend = NativeStorageBackend(file);
        await expectLater(
          FixtureRepository(migrationBackend, failMigration: true).snapshot(),
          throwsA(
            predicate(
              (e) => e.toString().contains('Injected migration failure'),
            ),
          ),
        );
        expect(file.readAsBytesSync(), original);
        final upgraded = await FixtureRepository(migrationBackend).snapshot();
        expect(upgraded.items.single.id, 'older-child');
        expect(upgraded.items.single.collectionId, 'older-parent');
        await migrationBackend.dispose();
        directory.deleteSync(recursive: true);
      }
      final backend = await createBackend(fixtureNamespace);
      final repository = FixtureRepository(backend);
      await repository.reset();
      await repository.seed();
      final container = ProviderContainer(
        overrides: [
          fixtureModeProvider.overrideWithValue(true),
          resourcesProvider.overrideWith(
            (ref) async => AppResources(backend, repository),
          ),
        ],
      );
      final screenshotKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: screenshotKey,
          child: UncontrolledProviderScope(
            container: container,
            child: const DocketApp(),
          ),
        ),
      );
      final router = container.read(routerProvider);
      for (var i = 0; i < 100 && find.text('Docket').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      router.go('/lists/collection-a');
      await tester.pumpAndSettle();
      final shell = tester.state<FoundationShellState>(
        find.byType(FoundationShell),
      );
      // Pointer activation is dispatched to the actual native Flutter view.
      await tester.tap(find.byKey(const ValueKey('row-item-000')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('fixture-title')),
        'Native committed value',
      );
      final save = find.byKey(const ValueKey('save-fixture'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      for (var i = 0; i < 100 && shell.drafts['item-000']!.saving; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(shell.drafts['item-000']!.message, 'Saved on this device');
      repository.failNextWrite = true;
      shell.drafts['item-000']!.title.text = 'Native retained draft';
      await shell.drafts['item-000']!.save(repository);
      await tester.pumpAndSettle();
      expect(shell.drafts['item-000']!.message, contains('Not saved'));
      expect(
        (await repository.snapshot()).items.first.title,
        'Native committed value',
      );
      shell.detailScroll.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fixture-title')));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(
        shell.drafts['item-000']!.title.selection.extentOffset,
        'Native retained draft'.length,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(shell.rowFocus['item-000']!.hasFocus, true);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        contains('/items/item-000'),
      );
      if (Platform.isWindows) {
        for (final width in [800.0, 390.0, 1200.0]) {
          await tester.binding.setSurfaceSize(Size(width, 900));
          await tester.pumpAndSettle();
          expect(shell.drafts['item-000']!.title.text, 'Native retained draft');
          expect(tester.takeException(), isNull);
        }
        await tester.binding.setSurfaceSize(null);
        await tester.pumpAndSettle();
        final position = shell.scrolls['collection-a']!.offset;
        shell.detailScroll.jumpTo(150);
        await tester.pumpAndSettle();
        expect(shell.scrolls['collection-a']!.offset, position);
        shell.detailScroll.jumpTo(0);
      }

      final timings = <Map<String, int>>[];
      void record(List<ui.FrameTiming> frames) {
        for (final frame in frames) {
          timings.add({
            'buildUs': frame.buildDuration.inMicroseconds,
            'rasterUs': frame.rasterDuration.inMicroseconds,
            'totalUs': frame.totalSpan.inMicroseconds,
          });
        }
      }

      WidgetsBinding.instance.addTimingsCallback(record);
      var completed = false;
      var updates = 0;
      final workload = repository
          .bulkWrite(
            progress: (_) {
              updates++;
            },
          )
          .then((elapsed) {
            completed = true;
            return elapsed;
          });
      var interactionFrames = 0;
      while (!completed) {
        router.go(
          interactionFrames.isEven
              ? '/lists/collection-a'
              : '/lists/collection-a/items/item-000',
        );
        await tester.pump(const Duration(milliseconds: 16));
        final scroll = shell.scrolls['collection-a'];
        if (scroll != null && scroll.hasClients) {
          scroll.jumpTo((interactionFrames * 30.0) % 400);
        }
        interactionFrames++;
      }
      final elapsed = await workload;
      await tester.pumpAndSettle();
      WidgetsBinding.instance.removeTimingsCallback(record);
      expect(
        (await repository.snapshot()).items
            .where((item) => item.collectionId == 'bulk')
            .length,
        10000,
      );
      expect(updates, 40);
      expect(interactionFrames, greaterThan(0));
      final output = Platform.isWindows
          ? Directory('docs/evidence')
          : Directory.systemTemp;
      await output.create(recursive: true);
      await File('${output.path}/native-responsiveness.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'platform': Platform.operatingSystem,
          'build': 'integration_test debug native runner',
          'recordCount': 10000,
          'elapsedMs': elapsed.inMilliseconds,
          'progressUpdates': updates,
          'navigationAndScrollFrames': interactionFrames,
          'frames': timings,
          'input':
              'Flutter integration-test pointer/key dispatch; not manual OS input',
        }),
      );
      router.go('/lists/collection-a/items/item-000');
      await tester.pumpAndSettle();
      final boundary =
          screenshotKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final screenshot = await boundary.toImage(pixelRatio: 1);
      final png = await screenshot.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '${output.path}/native-foundation.png',
      ).writeAsBytes(png!.buffer.asUint8List());
      screenshot.dispose();
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await backend.dispose();
    },
  );
}
