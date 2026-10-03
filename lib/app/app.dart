import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/shell/foundation_shell.dart';
import 'bootstrap.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/lists',
    routes: [
      ShellRoute(
        builder: (context, state, child) => Stack(
          children: [
            Offstage(child: child),
            FoundationShell(
              collectionId: state.pathParameters['collectionId'],
              itemId: state.pathParameters['itemId'],
            ),
          ],
        ),
        routes: [
          for (final path in [
            '/lists',
            '/lists/:collectionId',
            '/lists/:collectionId/items/:itemId',
          ])
            GoRoute(path: path, builder: (_, _) => const SizedBox.shrink()),
        ],
      ),
      GoRoute(path: '/', redirect: (_, _) => '/lists'),
    ],
    errorBuilder: (context, _) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Page unavailable'),
            TextButton(
              onPressed: () => context.go('/lists'),
              child: const Text('Open lists'),
            ),
          ],
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

class DocketApp extends ConsumerWidget {
  const DocketApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: ref.watch(fixtureModeProvider)
        ? 'Docket · Foundation fixture'
        : 'Docket',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5264bd)),
      scaffoldBackgroundColor: const Color(0xfff6f7fb),
      focusColor: const Color(0xffc6d0ff),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    routerConfig: ref.watch(routerProvider),
  );
}
