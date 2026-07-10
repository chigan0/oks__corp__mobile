import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/construction_objects/objects_notifier.dart';
import '../features/connectivity/connectivity_notifier.dart';
import '../features/language_switcher/language_notifier.dart';
import '../shared/ui/offline_blocking_overlay.dart';
import 'di/app_dependencies.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class OksQrApp extends StatelessWidget {
  const OksQrApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dependencies.authNotifier),
        Provider.value(value: dependencies.authenticatedDio),
        Provider.value(value: dependencies.tokenStorage),
        Provider.value(value: dependencies.profileApi),
        Provider.value(value: dependencies.qrGenerationApi),
        Provider.value(value: dependencies.qrValidationApi),
        Provider.value(value: dependencies.facilitiesApi),
        ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier()..init(),
        ),
        ChangeNotifierProvider(create: (_) => LanguageNotifier()),
        ChangeNotifierProvider(
          create: (_) => ObjectsNotifier(api: dependencies.facilitiesApi),
        ),
      ],
      child: MaterialApp.router(
        title: 'OKS Corp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: createAppRouter(dependencies.authNotifier),
        builder: (context, child) {
          final isOffline = context.select<ConnectivityNotifier, bool>(
            (notifier) => notifier.isOffline,
          );

          return OfflineAppShell(
            isOffline: isOffline,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _initFuture = AppDependencies.instance.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Failed to initialize app: ${snapshot.error}'),
              ),
            ),
          );
        }

        return OksQrApp(dependencies: AppDependencies.instance);
      },
    );
  }
}
