import 'dart:io';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docket/app/app.dart';
import 'package:docket/app/bootstrap.dart';
import 'package:docket/data/local/fixture_repository.dart';
import 'package:docket/features/shell/foundation_shell.dart';
import 'package:docket/platform/connection_native.dart';

Future<void> settleStorage(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 40));
  }
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

class WidgetStorageBackend extends NativeStorageBackend {
  WidgetStorageBackend(super.file);
  @override
  Future<QueryExecutor> connect() async => NativeDatabase(file);
}

void main() {
  test('minimum widths and large text choose usable composition', () {
    expect(PaneConstraints.at(600, 1), PaneLayout.compact);
    expect(PaneConstraints.at(601, 1), PaneLayout.intermediate);
    expect(PaneConstraints.at(921, 1), PaneLayout.intermediate);
    expect(PaneConstraints.at(922, 1), PaneLayout.wide);
    expect(PaneConstraints.at(1200, 2), PaneLayout.compact);
    expect(PaneConstraints.at(1202, 2), PaneLayout.intermediate);
  });

  testWidgets(
    'ordinary startup is auth-free, fixture-free, and reports local failure',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('docket-shell-');
      final file = File('${directory.path}/local.sqlite');
      final container = ProviderContainer(
        overrides: [
          backendFactoryProvider.overrideWithValue(
            (_) async => WidgetStorageBackend(file),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DocketApp(),
        ),
      );
      await settleStorage(tester);
      expect(find.text('Local only'), findsOneWidget);
      expect(find.textContaining('FOUNDATION FIXTURE'), findsNothing);
      expect(find.text('Save locally'), findsNothing);
      expect(find.textContaining('Sign in'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(
        () => file.writeAsString('preserve original bytes'),
      );
      final broken = ProviderContainer(
        overrides: [
          backendFactoryProvider.overrideWithValue(
            (_) async => WidgetStorageBackend(file),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(container: broken, child: const DocketApp()),
      );
      await settleStorage(tester);
      expect(find.text('Local storage could not be opened'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(
        await tester.runAsync(file.readAsString),
        'preserve original bytes',
      );
      await tester.pumpWidget(const SizedBox());
      broken.dispose();
      await tester.runAsync(() => directory.delete(recursive: true));
    },
  );

  testWidgets(
    'routes, draft, scroll, keyboard ownership, parent fallback and boundaries',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'docket-navigation-',
      );
      final backend = WidgetStorageBackend(
        File('${directory.path}/fixture.sqlite'),
      );
      final repository = FixtureRepository(backend);
      await tester.runAsync(repository.seed);
      final container = ProviderContainer(
        overrides: [
          fixtureModeProvider.overrideWithValue(true),
          resourcesProvider.overrideWith(
            (ref) async => AppResources(backend, repository),
          ),
        ],
      );
      final router = container.read(routerProvider);
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DocketApp(),
        ),
      );
      await settleStorage(tester);
      router.go('/lists/collection-a');
      await tester.pumpAndSettle();
      var shell = tester.state<FoundationShellState>(
        find.byType(FoundationShell),
      );
      shell.scrolls['collection-a']!.jumpTo(900);
      await tester.pumpAndSettle();
      final beforeScroll = shell.scrolls['collection-a']!.offset;
      router.go('/lists/collection-a/items/item-016');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('wide')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('fixture-title')),
        'retained draft',
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      shell = tester.state<FoundationShellState>(find.byType(FoundationShell));
      expect(shell.drafts['item-016']!.title.selection.baseOffset, 0);
      expect(
        shell.drafts['item-016']!.title.selection.extentOffset,
        'retained draft'.length,
      );
      for (final width in [921.0, 601.0, 600.0, 390.0, 922.0, 1200.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpAndSettle();
        expect(find.text('retained draft'), findsOneWidget);
        expect(shell.drafts['item-016']!.titleFocus.hasFocus, true);
        expect(tester.takeException(), isNull);
      }
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('compact')), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.pumpAndSettle();
      final collectionOffset = shell.scrolls['collection-a']!.offset;
      shell.detailScroll.jumpTo(150);
      await tester.pumpAndSettle();
      expect(shell.scrolls['collection-a']!.offset, collectionOffset);
      shell.detailScroll.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('close-detail')));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/lists/collection-a',
      );
      expect(shell.scrolls['collection-a']!.offset, closeTo(beforeScroll, 1));
      expect(shell.rowFocus['item-016']!.hasFocus, true);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/lists/collection-a/items/item-016',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/lists/collection-a',
      );
      // Direct URL, with no Navigator push history, still has a deterministic parent.
      router.go('/lists/collection-a/items/item-001');
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/lists/collection-a',
      );
      router.go('/lists/collection-a/items/missing');
      await tester.pumpAndSettle();
      expect(find.text('Fixture unavailable'), findsOneWidget);
      await tester.tap(find.text('Open parent collection'));
      await tester.pumpAndSettle();
      router.go('/lists/missing/items/missing');
      await tester.pumpAndSettle();
      expect(find.text('Open collections'), findsOneWidget);
      router.go('/lists/collection-a/items/item-001');
      await tester.pumpAndSettle();
      await tester.runAsync(repository.reset);
      await settleStorage(tester);
      shell.parent();
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/lists');
      expect(shell.homeFocus.hasFocus, true);
      router.go('/invalid');
      await tester.pumpAndSettle();
      expect(find.text('Page unavailable'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(() async {
        await backend.dispose();
        await directory.delete(recursive: true);
      });
    },
  );
}
