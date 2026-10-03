import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:web/web.dart' as web;
import 'storage_backend.dart';

@JS('docketSchema.read')
external JSPromise<JSNumber> _readVersion(JSString namespace);
@JS('docketSchema.write')
external JSPromise<JSAny?> _writeVersion(JSString namespace, JSNumber version);

Future<StorageBackend> createBackend(String namespace) =>
    _createBackend(namespace);

// Called only from the explicitly compiled acceptance entrypoint.
Future<StorageBackend> createAcceptanceBackend(
  String namespace,
  String? forcedMode,
) => _createBackend(namespace, forcedMode: forcedMode);

Future<StorageBackend> _createBackend(
  String namespace, {
  String? forcedMode,
}) async {
  if (![localNamespace, fixtureNamespace].contains(namespace)) {
    throw ArgumentError('Unknown application namespace');
  }
  final probe = await WasmDatabase.probe(
    sqlite3Uri: Uri.base.resolve('/sqlite3.wasm'),
    driftWorkerUri: Uri.base.resolve('/drift_worker.js'),
    databaseName: namespace,
  );
  final supported = probe.availableStorages;
  final existing = probe.existingDatabases
      .where((db) => db.$2 == namespace)
      .toList();
  if (existing.length > 1) {
    throw StateError(
      'Multiple fixture storage locations exist. Preserve site data and export before selecting a store.',
    );
  }
  final chosen = forcedMode != null
      ? WasmStorageImplementation.values.byName(forcedMode)
      : WasmStorageImplementation.values.firstWhere(
          (mode) =>
              supported.contains(mode) &&
              (existing.isEmpty || mode.storageApi == existing.single.$1),
          orElse: () => WasmStorageImplementation.inMemory,
        );
  final safe =
      {
        WasmStorageImplementation.opfsShared,
        WasmStorageImplementation.opfsLocks,
        WasmStorageImplementation.sharedIndexedDb,
      }.contains(chosen) &&
      web.window.navigator.hasProperty('locks'.toJS).toDart;
  var protected = false;
  try {
    protected = (await web.window.navigator.storage.persist().toDart).toDart;
  } catch (_) {
    /* Permission is an eviction risk, not a capability failure. */
  }
  return WebStorageBackend(
    namespace,
    probe,
    chosen,
    StorageHealth(mode: chosen.name, safe: safe, evictionProtected: protected),
  );
}

class WebStorageBackend extends StorageBackend {
  WebStorageBackend(
    this.namespace,
    this.probe,
    this.implementation,
    this.health,
  ) {
    channel.onmessage = ((web.MessageEvent _) {
      events.add(null);
    }).toJS;
  }
  final String namespace;
  final WasmProbeResult probe;
  final WasmStorageImplementation implementation;
  @override
  final StorageHealth health;
  final events = StreamController<void>.broadcast();
  late final channel = web.BroadcastChannel('$namespace:commits');
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<QueryExecutor> connect() async =>
      probe.open(implementation, namespace);

  /// Every operation includes open/version-check/migrate/query/commit/close.
  /// No idle tab retains a SQLite handle across an upgrade. Browser-owned lock
  /// release on termination needs no timeout that could split lock ownership.
  @override
  Future<T> coordinate<T>(Future<T> Function() operation) async {
    late T result;
    Object? failure;
    StackTrace? trace;
    await web.window.navigator.locks
        .request(
          '$namespace:schema-and-access',
          ((web.Lock _) => (() async {
            try {
              final version = namespace == fixtureNamespace ? 2 : 1;
              final previous = (await _readVersion(
                namespace.toJS,
              ).toDart).toDartInt;
              if (previous > version) {
                throw StateError(
                  'Update required. This shell cannot write schema $previous. Drafts and stored data are preserved.',
                );
              }
              result = await operation();
            } catch (e, s) {
              failure = e;
              trace = s;
            }
            return null;
          })().toJS).toJS,
        )
        .toDart;
    if (failure != null) Error.throwWithStackTrace(failure!, trace!);
    return result;
  }

  @override
  void committed() {
    events.add(null);
    channel.postMessage('committed'.toJS);
  }

  @override
  Future<void> recordSchemaVersion(int version) async {
    await _writeVersion(namespace.toJS, version.toJS).toDart;
  }

  @override
  Future<String?> recoverFixture() async {
    if (namespace != fixtureNamespace) return null;
    return coordinate(() async {
      final existing = probe.existingDatabases
          .where((db) => db.$2 == namespace)
          .toList();
      if (existing.isEmpty) {
        return 'No existing fixture store was found. Site data has not been reset.';
      }
      final snapshots = <String, String>{};
      for (final location in existing) {
        final bytes = await probe.exportDatabase(location);
        if (bytes != null) snapshots[location.$1.name] = base64Encode(bytes);
      }
      return jsonEncode({
        'kind': 'fixture-recovery-sqlite-base64',
        'stores': snapshots,
      });
    });
  }

  @override
  Future<void> dispose() async {
    channel.close();
    await events.close();
  }
}
