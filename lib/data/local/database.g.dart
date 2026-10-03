// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BootstrapEntriesTable extends BootstrapEntries
    with TableInfo<$BootstrapEntriesTable, BootstrapEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BootstrapEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bootstrap_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BootstrapEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  BootstrapEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BootstrapEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $BootstrapEntriesTable createAlias(String alias) {
    return $BootstrapEntriesTable(attachedDatabase, alias);
  }
}

class BootstrapEntry extends DataClass implements Insertable<BootstrapEntry> {
  final String key;
  final String value;
  const BootstrapEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  BootstrapEntriesCompanion toCompanion(bool nullToAbsent) {
    return BootstrapEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory BootstrapEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BootstrapEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  BootstrapEntry copyWith({String? key, String? value}) =>
      BootstrapEntry(key: key ?? this.key, value: value ?? this.value);
  BootstrapEntry copyWithCompanion(BootstrapEntriesCompanion data) {
    return BootstrapEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BootstrapEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BootstrapEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class BootstrapEntriesCompanion extends UpdateCompanion<BootstrapEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const BootstrapEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BootstrapEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<BootstrapEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BootstrapEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return BootstrapEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BootstrapEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BootstrapDatabase extends GeneratedDatabase {
  _$BootstrapDatabase(QueryExecutor e) : super(e);
  $BootstrapDatabaseManager get managers => $BootstrapDatabaseManager(this);
  late final $BootstrapEntriesTable bootstrapEntries = $BootstrapEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bootstrapEntries];
}

typedef $$BootstrapEntriesTableCreateCompanionBuilder =
    BootstrapEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$BootstrapEntriesTableUpdateCompanionBuilder =
    BootstrapEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$BootstrapEntriesTableFilterComposer
    extends Composer<_$BootstrapDatabase, $BootstrapEntriesTable> {
  $$BootstrapEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BootstrapEntriesTableOrderingComposer
    extends Composer<_$BootstrapDatabase, $BootstrapEntriesTable> {
  $$BootstrapEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BootstrapEntriesTableAnnotationComposer
    extends Composer<_$BootstrapDatabase, $BootstrapEntriesTable> {
  $$BootstrapEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$BootstrapEntriesTableTableManager
    extends
        RootTableManager<
          _$BootstrapDatabase,
          $BootstrapEntriesTable,
          BootstrapEntry,
          $$BootstrapEntriesTableFilterComposer,
          $$BootstrapEntriesTableOrderingComposer,
          $$BootstrapEntriesTableAnnotationComposer,
          $$BootstrapEntriesTableCreateCompanionBuilder,
          $$BootstrapEntriesTableUpdateCompanionBuilder,
          (
            BootstrapEntry,
            BaseReferences<
              _$BootstrapDatabase,
              $BootstrapEntriesTable,
              BootstrapEntry
            >,
          ),
          BootstrapEntry,
          PrefetchHooks Function()
        > {
  $$BootstrapEntriesTableTableManager(
    _$BootstrapDatabase db,
    $BootstrapEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BootstrapEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BootstrapEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BootstrapEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BootstrapEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => BootstrapEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BootstrapEntriesTable, BootstrapEntry>(table),
                  BaseReferences<
                    _$BootstrapDatabase,
                    $BootstrapEntriesTable,
                    BootstrapEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BootstrapEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$BootstrapDatabase,
      $BootstrapEntriesTable,
      BootstrapEntry,
      $$BootstrapEntriesTableFilterComposer,
      $$BootstrapEntriesTableOrderingComposer,
      $$BootstrapEntriesTableAnnotationComposer,
      $$BootstrapEntriesTableCreateCompanionBuilder,
      $$BootstrapEntriesTableUpdateCompanionBuilder,
      (
        BootstrapEntry,
        BaseReferences<
          _$BootstrapDatabase,
          $BootstrapEntriesTable,
          BootstrapEntry
        >,
      ),
      BootstrapEntry,
      PrefetchHooks Function()
    >;

class $BootstrapDatabaseManager {
  final _$BootstrapDatabase _db;
  $BootstrapDatabaseManager(this._db);
  $$BootstrapEntriesTableTableManager get bootstrapEntries =>
      $$BootstrapEntriesTableTableManager(_db, _db.bootstrapEntries);
}

class $FixtureCollectionsTable extends FixtureCollections
    with TableInfo<$FixtureCollectionsTable, FixtureCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixtureCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixture_collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixtureCollection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixtureCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixtureCollection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
    );
  }

  @override
  $FixtureCollectionsTable createAlias(String alias) {
    return $FixtureCollectionsTable(attachedDatabase, alias);
  }
}

class FixtureCollection extends DataClass
    implements Insertable<FixtureCollection> {
  final String id;
  final String title;
  const FixtureCollection({required this.id, required this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    return map;
  }

  FixtureCollectionsCompanion toCompanion(bool nullToAbsent) {
    return FixtureCollectionsCompanion(id: Value(id), title: Value(title));
  }

  factory FixtureCollection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixtureCollection(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
    };
  }

  FixtureCollection copyWith({String? id, String? title}) =>
      FixtureCollection(id: id ?? this.id, title: title ?? this.title);
  FixtureCollection copyWithCompanion(FixtureCollectionsCompanion data) {
    return FixtureCollection(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixtureCollection(')
          ..write('id: $id, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixtureCollection &&
          other.id == this.id &&
          other.title == this.title);
}

class FixtureCollectionsCompanion extends UpdateCompanion<FixtureCollection> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> rowid;
  const FixtureCollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FixtureCollectionsCompanion.insert({
    required String id,
    required String title,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<FixtureCollection> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FixtureCollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? rowid,
  }) {
    return FixtureCollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixtureCollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FixtureItemsTable extends FixtureItems
    with TableInfo<$FixtureItemsTable, FixtureItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixtureItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixture_collections (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, collectionId, title, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixture_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixtureItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixtureItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixtureItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $FixtureItemsTable createAlias(String alias) {
    return $FixtureItemsTable(attachedDatabase, alias);
  }
}

class FixtureItem extends DataClass implements Insertable<FixtureItem> {
  final String id;
  final String collectionId;
  final String title;
  final String notes;
  const FixtureItem({
    required this.id,
    required this.collectionId,
    required this.title,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  FixtureItemsCompanion toCompanion(bool nullToAbsent) {
    return FixtureItemsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      title: Value(title),
      notes: Value(notes),
    );
  }

  factory FixtureItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixtureItem(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
    };
  }

  FixtureItem copyWith({
    String? id,
    String? collectionId,
    String? title,
    String? notes,
  }) => FixtureItem(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    title: title ?? this.title,
    notes: notes ?? this.notes,
  );
  FixtureItem copyWithCompanion(FixtureItemsCompanion data) {
    return FixtureItem(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixtureItem(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectionId, title, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixtureItem &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.title == this.title &&
          other.notes == this.notes);
}

class FixtureItemsCompanion extends UpdateCompanion<FixtureItem> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> title;
  final Value<String> notes;
  final Value<int> rowid;
  const FixtureItemsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FixtureItemsCompanion.insert({
    required String id,
    required String collectionId,
    required String title,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       title = Value(title);
  static Insertable<FixtureItem> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FixtureItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? title,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return FixtureItemsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixtureItemsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FixtureDatabase extends GeneratedDatabase {
  _$FixtureDatabase(QueryExecutor e) : super(e);
  $FixtureDatabaseManager get managers => $FixtureDatabaseManager(this);
  late final $FixtureCollectionsTable fixtureCollections =
      $FixtureCollectionsTable(this);
  late final $FixtureItemsTable fixtureItems = $FixtureItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    fixtureCollections,
    fixtureItems,
  ];
}

typedef $$FixtureCollectionsTableCreateCompanionBuilder =
    FixtureCollectionsCompanion Function({
      required String id,
      required String title,
      Value<int> rowid,
    });
typedef $$FixtureCollectionsTableUpdateCompanionBuilder =
    FixtureCollectionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> rowid,
    });

final class $$FixtureCollectionsTableReferences
    extends
        BaseReferences<
          _$FixtureDatabase,
          $FixtureCollectionsTable,
          FixtureCollection
        > {
  $$FixtureCollectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FixtureItemsTable, List<FixtureItem>>
  _fixtureItemsRefsTable(_$FixtureDatabase db) => MultiTypedResultKey.fromTable(
    db.fixtureItems,
    aliasName: 'fixture_collections__id__fixture_items__collection_id',
  );

  $$FixtureItemsTableProcessedTableManager get fixtureItemsRefs {
    final manager = $$FixtureItemsTableTableManager(
      $_db,
      $_db.fixtureItems,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fixtureItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FixtureCollectionsTableFilterComposer
    extends Composer<_$FixtureDatabase, $FixtureCollectionsTable> {
  $$FixtureCollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fixtureItemsRefs(
    Expression<bool> Function($$FixtureItemsTableFilterComposer f) f,
  ) {
    final $$FixtureItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtureItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureItemsTableFilterComposer(
            $db: $db,
            $table: $db.fixtureItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixtureCollectionsTableOrderingComposer
    extends Composer<_$FixtureDatabase, $FixtureCollectionsTable> {
  $$FixtureCollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FixtureCollectionsTableAnnotationComposer
    extends Composer<_$FixtureDatabase, $FixtureCollectionsTable> {
  $$FixtureCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  Expression<T> fixtureItemsRefs<T extends Object>(
    Expression<T> Function($$FixtureItemsTableAnnotationComposer a) f,
  ) {
    final $$FixtureItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtureItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixtureCollectionsTableTableManager
    extends
        RootTableManager<
          _$FixtureDatabase,
          $FixtureCollectionsTable,
          FixtureCollection,
          $$FixtureCollectionsTableFilterComposer,
          $$FixtureCollectionsTableOrderingComposer,
          $$FixtureCollectionsTableAnnotationComposer,
          $$FixtureCollectionsTableCreateCompanionBuilder,
          $$FixtureCollectionsTableUpdateCompanionBuilder,
          (FixtureCollection, $$FixtureCollectionsTableReferences),
          FixtureCollection,
          PrefetchHooks Function({bool fixtureItemsRefs})
        > {
  $$FixtureCollectionsTableTableManager(
    _$FixtureDatabase db,
    $FixtureCollectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixtureCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixtureCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixtureCollectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixtureCollectionsCompanion(
                id: id,
                title: title,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<int> rowid = const Value.absent(),
              }) => FixtureCollectionsCompanion.insert(
                id: id,
                title: title,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixtureCollectionsTable, FixtureCollection>(
                    table,
                  ),
                  $$FixtureCollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fixtureItemsRefs) db.fixtureItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fixtureItemsRefs)
                    await $_getPrefetchedData<
                      FixtureCollection,
                      $FixtureCollectionsTable,
                      FixtureItem
                    >(
                      currentTable: table,
                      referencedTable: $$FixtureCollectionsTableReferences
                          ._fixtureItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FixtureCollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).fixtureItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FixtureCollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FixtureDatabase,
      $FixtureCollectionsTable,
      FixtureCollection,
      $$FixtureCollectionsTableFilterComposer,
      $$FixtureCollectionsTableOrderingComposer,
      $$FixtureCollectionsTableAnnotationComposer,
      $$FixtureCollectionsTableCreateCompanionBuilder,
      $$FixtureCollectionsTableUpdateCompanionBuilder,
      (FixtureCollection, $$FixtureCollectionsTableReferences),
      FixtureCollection,
      PrefetchHooks Function({bool fixtureItemsRefs})
    >;
typedef $$FixtureItemsTableCreateCompanionBuilder =
    FixtureItemsCompanion Function({
      required String id,
      required String collectionId,
      required String title,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$FixtureItemsTableUpdateCompanionBuilder =
    FixtureItemsCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String> title,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$FixtureItemsTableReferences
    extends BaseReferences<_$FixtureDatabase, $FixtureItemsTable, FixtureItem> {
  $$FixtureItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixtureCollectionsTable _collectionIdTable(_$FixtureDatabase db) => db
      .fixtureCollections
      .createAlias('fixture_items__collection_id__fixture_collections__id');

  $$FixtureCollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$FixtureCollectionsTableTableManager(
      $_db,
      $_db.fixtureCollections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FixtureItemsTableFilterComposer
    extends Composer<_$FixtureDatabase, $FixtureItemsTable> {
  $$FixtureItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$FixtureCollectionsTableFilterComposer get collectionId {
    final $$FixtureCollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.fixtureCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureCollectionsTableFilterComposer(
            $db: $db,
            $table: $db.fixtureCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixtureItemsTableOrderingComposer
    extends Composer<_$FixtureDatabase, $FixtureItemsTable> {
  $$FixtureItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixtureCollectionsTableOrderingComposer get collectionId {
    final $$FixtureCollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.fixtureCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureCollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.fixtureCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixtureItemsTableAnnotationComposer
    extends Composer<_$FixtureDatabase, $FixtureItemsTable> {
  $$FixtureItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$FixtureCollectionsTableAnnotationComposer get collectionId {
    final $$FixtureCollectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.collectionId,
          referencedTable: $db.fixtureCollections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FixtureCollectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fixtureCollections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$FixtureItemsTableTableManager
    extends
        RootTableManager<
          _$FixtureDatabase,
          $FixtureItemsTable,
          FixtureItem,
          $$FixtureItemsTableFilterComposer,
          $$FixtureItemsTableOrderingComposer,
          $$FixtureItemsTableAnnotationComposer,
          $$FixtureItemsTableCreateCompanionBuilder,
          $$FixtureItemsTableUpdateCompanionBuilder,
          (FixtureItem, $$FixtureItemsTableReferences),
          FixtureItem,
          PrefetchHooks Function({bool collectionId})
        > {
  $$FixtureItemsTableTableManager(
    _$FixtureDatabase db,
    $FixtureItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixtureItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixtureItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixtureItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixtureItemsCompanion(
                id: id,
                collectionId: collectionId,
                title: title,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                required String title,
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixtureItemsCompanion.insert(
                id: id,
                collectionId: collectionId,
                title: title,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixtureItemsTable, FixtureItem>(table),
                  $$FixtureItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable: $$FixtureItemsTableReferences
                                    ._collectionIdTable(db),
                                referencedColumn: $$FixtureItemsTableReferences
                                    ._collectionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FixtureItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$FixtureDatabase,
      $FixtureItemsTable,
      FixtureItem,
      $$FixtureItemsTableFilterComposer,
      $$FixtureItemsTableOrderingComposer,
      $$FixtureItemsTableAnnotationComposer,
      $$FixtureItemsTableCreateCompanionBuilder,
      $$FixtureItemsTableUpdateCompanionBuilder,
      (FixtureItem, $$FixtureItemsTableReferences),
      FixtureItem,
      PrefetchHooks Function({bool collectionId})
    >;

class $FixtureDatabaseManager {
  final _$FixtureDatabase _db;
  $FixtureDatabaseManager(this._db);
  $$FixtureCollectionsTableTableManager get fixtureCollections =>
      $$FixtureCollectionsTableTableManager(_db, _db.fixtureCollections);
  $$FixtureItemsTableTableManager get fixtureItems =>
      $$FixtureItemsTableTableManager(_db, _db.fixtureItems);
}
