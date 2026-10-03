import 'dart:async';
import 'package:drift/drift.dart';

const localNamespace = 'docket_local';
const fixtureNamespace = 'docket_foundation_fixture';

class StorageHealth {
  const StorageHealth({
    required this.mode,
    required this.safe,
    this.evictionProtected = false,
  });
  final String mode;
  final bool safe;
  final bool evictionProtected;
  String get description => !safe
      ? 'Safe persistent storage is unavailable. Writes are disabled. '
            'Use a supported browser or native app; keep existing site data.'
      : '$mode · ${evictionProtected ? 'persistent storage granted' : 'storage may be evicted; this is not a backup'}';
}

abstract class StorageBackend {
  StorageHealth get health;
  Stream<void> get changes;
  Future<QueryExecutor> connect();
  Future<T> coordinate<T>(Future<T> Function() operation);
  Future<void> recordSchemaVersion(int version) async {}
  Future<String?> recoverFixture() async => null;
  void committed();
  Future<void> dispose();
}

/// Serializes in-process opens, including migration and close. On the web this
/// contract is implemented by an origin-wide Web Lock owned by the browser.
abstract class SerialStorageBackend extends StorageBackend {
  Future<void> _tail = Future.value();
  final events = StreamController<void>.broadcast();
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<T> coordinate<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  void committed() => events.add(null);
  @override
  Future<void> dispose() async {
    await _tail;
    await events.close();
  }
}
