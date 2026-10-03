import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'storage_backend.dart';

Future<StorageBackend> createBackend(String namespace) async {
  if (![localNamespace, fixtureNamespace].contains(namespace)) {
    throw ArgumentError('Unknown application namespace');
  }
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  return NativeStorageBackend(
    File(p.join(directory.path, '$namespace.sqlite')),
  );
}

class NativeStorageBackend extends SerialStorageBackend {
  NativeStorageBackend(this.file);
  final File file;
  @override
  StorageHealth get health => const StorageHealth(
    mode: 'Native SQLite · background isolate',
    safe: true,
    evictionProtected: true,
  );
  @override
  Future<QueryExecutor> connect() async =>
      NativeDatabase.createInBackground(file);
}
