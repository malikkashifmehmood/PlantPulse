import 'package:flutter/material.dart';

class PlantPulseColors {
  static const forest = Color(0xFF0D4A2A);
  static const green = Color(0xFF168447);
  static const bright = Color(0xFF35B968);
  static const mint = Color(0xFFE8F6EC);
  static const cream = Color(0xFFF7FAF6);
  static const ink = Color(0xFF102117);
  static const muted = Color(0xFF66756B);
  static const line = Color(0xFFDDE7DF);
  static const warning = Color(0xFFE99A22);
  static const warningBg = Color(0xFFFFF4DF);
  static const danger = Color(0xFFD84A4A);
  static const dangerBg = Color(0xFFFFEBEB);
  static const successBg = Color(0xFFE9F8EE);
  static const white = Colors.white;
}

ThemeData buildPlantPulseTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PlantPulseColors.green,
    brightness: Brightness.light,
  ).copyWith(
    primary: PlantPulseColors.green,
    onPrimary: Colors.white,
    secondary: PlantPulseColors.bright,
    surface: Colors.white,
    onSurface: PlantPulseColors.ink,
    outline: PlantPulseColors.line,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PlantPulseColors.cream,
    fontFamily: 'sans',
    appBarTheme: const AppBarTheme(
      backgroundColor: PlantPulseColors.cream,
      surfaceTintColor: Colors.transparent,
      foregroundColor: PlantPulseColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PlantPulseColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PlantPulseColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: PlantPulseColors.green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: PlantPulseColors.mint,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PlantPulseColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
