import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

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
    return MaterialApp(
      title: 'PlantPulse',
      debugShowCheckedModeBanner: false,
      theme: buildPlantPulseTheme(),
      home: const SplashScreen(),
    );
  }
}
