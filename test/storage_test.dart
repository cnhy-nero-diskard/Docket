import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:docket/data/local/database.dart';
import 'package:docket/data/local/fixture_repository.dart';
import 'package:docket/features/shell/editor_draft.dart';
import 'package:docket/platform/connection_native.dart';
import 'package:docket/platform/storage_backend.dart';

void main() {
  late Directory directory;
  late NativeStorageBackend backend;
  late FixtureRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('docket-storage-');
    backend = NativeStorageBackend(File('${directory.path}/fixture.sqlite'));
    repository = FixtureRepository(backend);
  });
  tearDown(() async {
    await backend.dispose();
    await directory.delete(recursive: true);
  });

  test(
    'independent on-disk bootstrap and fixture reopen; reset preserves sentinel',
    () async {
      final sentinel = File('${directory.path}/local.sqlite');
      var db = BootstrapDatabase(
        await NativeStorageBackend(sentinel).connect(),
      );
      await db.initialize();
      await db
          .into(db.bootstrapEntries)
          .insert(
            BootstrapEntriesCompanion.insert(key: 'sentinel', value: 'keep'),
          );
      await db.close();
      await repository.seed();
      expect((await FixtureRepository(backend).snapshot()).items.length, 80);
      await repository.reset();
      expect((await repository.snapshot()).items, isEmpty);
      db = BootstrapDatabase(await NativeStorageBackend(sentinel).connect());
      final values = await db.select(db.bootstrapEntries).get();
      expect(values.singleWhere((r) => r.key == 'sentinel').value, 'keep');
      await db.close();
    },
  );

  test(
    'foreign keys reject orphan and failed related mutation rolls back after reopen',
    () async {
      await repository.createPair('a', 'b');
      await expectLater(
        repository.read(
          (db) => db
              .into(db.fixtureItems)
              .insert(
                FixtureItemsCompanion.insert(
                  id: 'orphan',
                  collectionId: 'missing',
                  title: 'invalid',
                ),
              ),
        ),
        throwsA(anything),
      );
      await expectLater(
        repository.createPair('c', 'd', failBetween: true),
        throwsStateError,
      );
      final reopened = await FixtureRepository(backend).snapshot();
      expect(reopened.collections.map((r) => r.id), ['a']);
      expect(reopened.items.map((r) => r.id), ['b']);
    },
  );

  test('two observers receive only committed values', () async {
    await repository.createPair('a', 'b');
    final first = StreamIterator(repository.watch());
    final second = StreamIterator(repository.watch());
    await first.moveNext();
    await second.moveNext();
    final nextA = first.moveNext();
    final nextB = second.moveNext();
    await repository.save('b', 'committed', 'notes');
    expect(await nextA, true);
    expect(await nextB, true);
    expect(first.current.items.single.title, 'committed');
    expect(second.current.items.single.title, 'committed');
    await first.cancel();
    await second.cancel();
  });

  test(
    'editor acknowledges commit and retains draft on injected failure',
    () async {
      await repository.createPair('a', 'b');
      final draft = EditorDraft((await repository.snapshot()).items.single);
      draft.title.text = 'proposed';
      repository.failNextWrite = true;
      final save = draft.save(repository);
      expect(draft.saving, true);
      expect(draft.message, isNull);
      await save;
      expect(draft.title.text, 'proposed');
      expect(draft.dirty, true);
      expect(draft.message, contains('Not saved'));
      expect((await repository.snapshot()).items.single.title, 'Atomic child');
      await draft.save(repository);
      expect(draft.message, 'Saved on this device');
      expect(draft.dirty, false);
      expect((await repository.snapshot()).items.single.title, 'proposed');
      draft.dispose();
    },
  );

  for (final version in [1, 2]) {
    test(
      'populated v$version opens v2 preserving identity and relationships',
      () async {
        final raw = sqlite.sqlite3.open(backend.file.path);
        raw.execute(await File('test/fixtures/v$version.sql').readAsString());
        raw.close();
        final data = await repository.snapshot();
        expect(data.collections.single.id, 'older-parent');
        expect(data.items.single.id, 'older-child');
        expect(data.items.single.collectionId, 'older-parent');
        expect(data.items.single.title, 'Preserved text');
        expect(
          data.items.single.notes,
          version == 1 ? '' : 'Version two notes',
        );
      },
    );
  }

  test(
    'selection is not a draft; pristine editors follow commits without overwriting edits',
    () async {
      await repository.createPair('a', 'b');
      final original = (await repository.snapshot()).items.single;
      final draft = EditorDraft(original);
      draft.title.selection = const TextSelection.collapsed(offset: 1);
      expect(draft.dirty, false);
      draft.acceptCommitted(
        original.copyWith(title: 'Another committed value'),
      );
      expect(draft.title.text, 'Another committed value');
      expect(draft.dirty, false);
      draft.title.text = 'Local unsaved draft';
      draft.acceptCommitted(original.copyWith(title: 'Concurrent value'));
      expect(draft.title.text, 'Local unsaved draft');
      expect(draft.dirty, true);
      draft.dispose();
    },
  );

  test(
    'failed migration rolls back; closed-store snapshot and newer database survive',
    () async {
      var raw = sqlite.sqlite3.open(backend.file.path);
      raw.execute(await File('test/fixtures/v1.sql').readAsString());
      raw.close();
      // The closed source has no active journal: this is a consistent fixture snapshot.
      final before = await backend.file.readAsBytes();
      await expectLater(
        FixtureRepository(backend, failMigration: true).snapshot(),
        throwsA(
          predicate((e) => e.toString().contains('Injected migration failure')),
        ),
      );
      raw = sqlite.sqlite3.open(backend.file.path);
      expect(raw.select('PRAGMA user_version').single['user_version'], 1);
      expect(raw.select('PRAGMA table_info(fixture_items)').length, 3);
      expect(
        raw.select('SELECT title FROM fixture_items').single['title'],
        'Preserved text',
      );
      raw.close();
      expect(await backend.file.readAsBytes(), before);
      await repository.snapshot();
      raw = sqlite.sqlite3.open(backend.file.path);
      raw.execute('PRAGMA user_version = 99');
      raw.close();
      final newer = await backend.file.readAsBytes();
      await expectLater(
        repository.save('older-child', 'must not write', ''),
        throwsA(predicate((e) => e.toString().contains('Update required'))),
      );
      expect(await backend.file.readAsBytes(), newer);
    },
  );

  test('unopenable bootstrap preserves original bytes', () async {
    final file = File('${directory.path}/broken.sqlite');
    await file.writeAsString('existing recoverable bytes');
    final db = BootstrapDatabase(await NativeStorageBackend(file).connect());
    await expectLater(db.initialize(), throwsA(anything));
    await db.close();
    expect(await file.readAsString(), 'existing recoverable bytes');
  });

  test(
    'unsafe mode blocks writes; permission denial alone allows safe storage',
    () async {
      final unsafe = _HealthBackend(backend.file, false);
      await expectLater(FixtureRepository(unsafe).seed(), throwsStateError);
      expect(await backend.file.exists(), false);
      await unsafe.dispose();
      final safe = _HealthBackend(backend.file, true);
      await FixtureRepository(safe).createPair('p', 'c');
      expect((await FixtureRepository(safe).snapshot()).items.single.id, 'c');
      await safe.dispose();
    },
  );
}

class _HealthBackend extends NativeStorageBackend {
  _HealthBackend(super.file, this.safe);
  final bool safe;
  @override
  StorageHealth get health =>
      StorageHealth(mode: 'injected capability', safe: safe);
}
