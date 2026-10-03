// Explicit browser acceptance entrypoint. Never used by ordinary/fixture releases.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';
import 'platform/connection_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  WidgetsBinding.instance.ensureSemantics();
  final container = ProviderContainer(
    overrides: [
      fixtureModeProvider.overrideWithValue(true),
      backendFactoryProvider.overrideWithValue(
        (name) =>
            createAcceptanceBackend(name, Uri.base.queryParameters['storage']),
      ),
    ],
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const DocketApp()),
  );
  final resources = await container.read(resourcesProvider.future);
  final repository = resources.fixtures!;
  final api = JSObject();
  api['mode'] = resources.backend.health.mode.toJS;
  api['safe'] = resources.backend.health.safe.toJS;
  api['protected'] = resources.backend.health.evictionProtected.toJS;
  api['seed'] = (() => repository.seed().then((_) => true.toJS).toJS).toJS;
  api['reset'] = (() => repository.reset().then((_) => true.toJS).toJS).toJS;
  api['snapshot'] =
      (() => repository.exportJson().then((json) => json.toJS).toJS).toJS;
  api['save'] =
      ((JSString id, JSString title) => repository
              .save(id.toDart, title.toDart, '')
              .then((_) => true.toJS)
              .toJS)
          .toJS;
  api['failWrite'] = (() {
    repository.failNextWrite = true;
  }).toJS;
  api['bulk'] =
      (() => repository
              .bulkWrite()
              .then((duration) => duration.inMilliseconds.toJS)
              .toJS)
          .toJS;
  api['route'] = ((JSString path) {
    container.read(routerProvider).go(path.toDart);
  }).toJS;
  // Simulates an incompatible future database while holding the same app lock.
  // Real migration preservation is separately checked against populated SQL.
  api['upgrade'] =
      (() => repository
              .read((db) async {
                await db.customStatement('PRAGMA user_version = 99');
                await resources.backend.recordSchemaVersion(99);
              })
              .then((_) {
                resources.backend.committed();
                return true.toJS;
              })
              .toJS)
          .toJS;
  globalContext['docketFixture'] = api;
}
