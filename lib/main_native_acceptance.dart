// Isolated process-kill probe. Build explicitly; never an application entrypoint.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';
import 'data/local/fixture_repository.dart';
import 'platform/connection_native.dart';
import 'platform/storage_backend.dart';

class NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('HTTP disabled by native acceptance probe');
}

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = NoNetwork();
  if (arguments.length != 2 || !['write', 'reopen'].contains(arguments.first)) {
    stderr.writeln('Expected write|reopen and an evidence JSON path');
    exit(64);
  }
  final output = File(arguments[1]);
  final backend = await createBackend(fixtureNamespace);
  final repository = FixtureRepository(backend);
  runApp(
    ProviderScope(
      overrides: [
        fixtureModeProvider.overrideWithValue(true),
        resourcesProvider.overrideWith(
          (ref) async => AppResources(backend, repository),
        ),
      ],
      child: const DocketApp(),
    ),
  );
  if (arguments.first == 'write') {
    await repository.seed();
    await repository.save(
      'item-000',
      'forced-process-reopen-sentinel',
      'Committed before termination',
    );
    await output.writeAsString(
      jsonEncode({
        'phase': 'committed',
        'network': 'HTTP disabled',
        'id': 'item-000',
        'value': 'forced-process-reopen-sentinel',
      }),
      flush: true,
    );
    // Keep this real Flutter process alive for external Stop-Process -Force.
  } else {
    final item = (await repository.snapshot()).items.singleWhere(
      (r) => r.id == 'item-000',
    );
    final passed =
        item.title == 'forced-process-reopen-sentinel' &&
        item.notes == 'Committed before termination';
    await output.writeAsString(
      jsonEncode({
        'phase': 'reopened',
        'outcome': passed ? 'PASS' : 'FAIL',
        'network': 'HTTP disabled',
        'id': item.id,
        'value': item.title,
      }),
      flush: true,
    );
    await backend.dispose();
    exit(passed ? 0 : 1);
  }
}
