import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppServicesScope>();

    assert(scope != null, 'AppServicesScope was not found in the widget tree.');

    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return services != oldWidget.services;
  }
}

class PlantPulseApp extends StatefulWidget {
  const PlantPulseApp({super.key, required this.services});

  final AppServices services;

  @override
  State<PlantPulseApp> createState() => _PlantPulseAppState();
}

class _PlantPulseAppState extends State<PlantPulseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.services.security.recordUserActivity();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: widget.services,
      child: MaterialApp(
        title: 'PlantPulse',
        debugShowCheckedModeBanner: false,
        theme: buildPlantPulseTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
