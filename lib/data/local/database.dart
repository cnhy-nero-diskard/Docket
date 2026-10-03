import 'package:drift/drift.dart';

part 'database.g.dart';

class BootstrapEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [BootstrapEntries])
class BootstrapDatabase extends _$BootstrapDatabase {
  BootstrapDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (_, from, to) async => throw StateError(
      'This local store needs a compatible application. Nothing was reset.',
    ),
  );

  Future<void> initialize() async {
    await into(bootstrapEntries).insert(
      BootstrapEntriesCompanion.insert(key: 'kind', value: 'local-only'),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

class FixtureCollections extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class FixtureItems extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text().references(FixtureCollections, #id)();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Disposable schema. Never use this as the production task schema.
@DriftDatabase(tables: [FixtureCollections, FixtureItems])
class FixtureDatabase extends _$FixtureDatabase {
  FixtureDatabase(super.executor, {this.failMigration = false});
  final bool failMigration;
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => transaction(m.createAll),
    onUpgrade: (m, from, to) async {
      if (from != 1 || to != 2) {
        throw StateError(
          'Update required: fixture schema $from is unsupported. '
          'The existing store has been preserved.',
        );
      }
      await transaction(() async {
        await m.addColumn(fixtureItems, fixtureItems.notes);
        if (failMigration) throw StateError('Injected migration failure');
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT COUNT(*) AS n FROM fixture_collections').get();
  }
}
