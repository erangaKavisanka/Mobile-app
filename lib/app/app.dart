import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../shared/widgets/state_views.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EcoLinkApp extends ConsumerWidget {
  const EcoLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(appBootstrapProvider);
    final mode =
        ref.watch(preferencesProvider).value?.themeMode ?? ThemeMode.system;

    return boot.when(
      loading: () =>
          _Plain(mode, const LoadingView(label: 'Starting EcoLink…')),
      error: (e, _) => _Plain(
        mode,
        ErrorState(
          message: 'EcoLink could not start: $e',
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
      ),
      data: (_) => MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: EcoTheme.light(),
        darkTheme: EcoTheme.dark(),
        themeMode: mode,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}

class _Plain extends StatelessWidget {
  const _Plain(this.mode, this.child);

  final ThemeMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: EcoTheme.light(),
    darkTheme: EcoTheme.dark(),
    themeMode: mode,
    home: Scaffold(body: SafeArea(child: child)),
  );
}
