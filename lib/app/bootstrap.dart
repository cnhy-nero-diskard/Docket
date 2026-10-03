import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import '../data/local/fixture_repository.dart';
import '../platform/connection.dart';
import '../platform/storage_backend.dart';

final fixtureModeProvider = Provider<bool>((ref) => false);
final backendFactoryProvider = Provider((ref) => createBackend);
final resourcesProvider = FutureProvider<AppResources>((ref) async {
  final fixture = ref.watch(fixtureModeProvider);
  final backend = await ref.watch(backendFactoryProvider)(
    fixture ? fixtureNamespace : localNamespace,
  );
  ref.onDispose(() {
    backend.dispose();
  });
  final repository = fixture ? FixtureRepository(backend) : null;
  if (backend.health.safe) {
    if (repository != null) {
      await repository.snapshot();
    } else {
      await backend.coordinate(() async {
        final db = BootstrapDatabase(await backend.connect());
        try {
          await db.initialize();
          await backend.recordSchemaVersion(db.schemaVersion);
        } finally {
          await db.close();
        }
      });
    }
  }
  return AppResources(backend, repository);
}, retry: (_, _) => null);

class AppResources {
  AppResources(this.backend, this.fixtures);
  final StorageBackend backend;
  final FixtureRepository? fixtures;
}
