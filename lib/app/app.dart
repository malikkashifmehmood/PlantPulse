import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

class PlantPulseApp extends StatelessWidget {
  const PlantPulseApp({super.key});

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
