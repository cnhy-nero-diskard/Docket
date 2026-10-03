import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../platform/storage_backend.dart';
import 'database.dart';

class FixtureSnapshot {
  const FixtureSnapshot(this.collections, this.items);
  final List<FixtureCollection> collections;
  final List<FixtureItem> items;
}

class FixtureRepository {
  FixtureRepository(this.backend, {this.failMigration = false});
  final StorageBackend backend;
  final bool failMigration;
  bool failNextWrite = false;

  Future<T> read<T>(Future<T> Function(FixtureDatabase) query) =>
      backend.coordinate(() async {
        final db = FixtureDatabase(
          await backend.connect(),
          failMigration: failMigration,
        );
        try {
          await db.initialize();
          await backend.recordSchemaVersion(db.schemaVersion);
          return await query(db);
        } finally {
          await db.close();
        }
      });

  Future<T> _write<T>(Future<T> Function(FixtureDatabase) command) async {
    if (!backend.health.safe) throw StateError(backend.health.description);
    final result = await read(
      (db) => db.transaction(() async {
        final result = await command(db);
        if (failNextWrite) {
          failNextWrite = false;
          throw StateError(
            'Injected storage failure. Your draft was not saved.',
          );
        }
        return result;
      }),
    );
    backend.committed();
    return result;
  }

  Future<FixtureSnapshot> snapshot() => read(
    (db) async => FixtureSnapshot(
      await (db.select(
        db.fixtureCollections,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get(),
      await (db.select(
        db.fixtureItems,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get(),
    ),
  );

  /// Subscribe before the initial query so a commit during subscription cannot
  /// be lost. Invalidation is emitted only after commit AND connection close.
  /// Browser commits are broadcast to other tabs, which recheck the version.
  Stream<FixtureSnapshot> watch() => Stream.multi((sink) {
    var cancelled = false;
    Future<void> tail = Future.value();
    void refresh() {
      tail = tail.then((_) async {
        if (cancelled) return;
        try {
          final data = await snapshot();
          if (!cancelled) sink.add(data);
        } catch (e, s) {
          if (!cancelled) sink.addError(e, s);
        }
      });
    }

    final subscription = backend.changes.listen((_) => refresh());
    sink.onCancel = () async {
      cancelled = true;
      await subscription.cancel();
    };
    refresh();
  });

  Future<void> seed() => _write((db) async {
    await db
        .into(db.fixtureCollections)
        .insert(
          FixtureCollectionsCompanion.insert(
            id: 'collection-a',
            title: 'Foundation collection',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    for (var i = 0; i < 80; i++) {
      await db
          .into(db.fixtureItems)
          .insert(
            FixtureItemsCompanion.insert(
              id: 'item-${i.toString().padLeft(3, '0')}',
              collectionId: 'collection-a',
              title: 'Fixture record ${i + 1}',
              notes: Value('Disposable foundation record.\n' * 12),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  });

  Future<void> save(String id, String title, String notes) => _write((
    db,
  ) async {
    final count =
        await (db.update(db.fixtureItems)..where((t) => t.id.equals(id))).write(
          FixtureItemsCompanion(title: Value(title), notes: Value(notes)),
        );
    if (count != 1) throw StateError('The fixture record no longer exists.');
  });

  Future<void> createPair(
    String collectionId,
    String itemId, {
    bool failBetween = false,
  }) => _write((db) async {
    await db
        .into(db.fixtureCollections)
        .insert(
          FixtureCollectionsCompanion.insert(
            id: collectionId,
            title: 'Atomic parent',
          ),
        );
    if (failBetween) {
      throw StateError('Injected failure between related writes');
    }
    await db
        .into(db.fixtureItems)
        .insert(
          FixtureItemsCompanion.insert(
            id: itemId,
            collectionId: collectionId,
            title: 'Atomic child',
          ),
        );
  });

  Future<void> reset() => _write((db) async {
    await db.delete(db.fixtureItems).go();
    await db.delete(db.fixtureCollections).go();
  });

  Future<String> exportJson() async {
    final data = await snapshot();
    return jsonEncode({
      'kind': 'disposable-foundation-fixture',
      'schema': 2,
      'collections': data.collections.map((r) => r.toJson()).toList(),
      'items': data.items.map((r) => r.toJson()).toList(),
    });
  }

  Future<Duration> bulkWrite({void Function(int)? progress}) async {
    final watch = Stopwatch()..start();
    await _write((db) async {
      await db
          .into(db.fixtureCollections)
          .insert(
            FixtureCollectionsCompanion.insert(
              id: 'bulk',
              title: '10,000-record workload',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      for (var start = 0; start < 10000; start += 250) {
        await db.batch(
          (b) => b.insertAll(
            db.fixtureItems,
            List.generate(
              250,
              (offset) => FixtureItemsCompanion.insert(
                id: 'bulk-${(start + offset).toString().padLeft(5, '0')}',
                collectionId: 'bulk',
                title: 'Workload record ${start + offset}',
              ),
            ),
            mode: InsertMode.insertOrIgnore,
          ),
        );
        progress?.call(start + 250);
        await Future<void>.delayed(Duration.zero);
      }
    });
    return watch.elapsed;
  }
}
