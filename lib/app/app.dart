import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/app_services.dart';
import '../features/splash/splash_screen.dart';
import '../l10n/app_localizations.dart';
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

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  final Locale locale;
  final Future<void> Function(Locale locale) setLocale;

  static AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();

    assert(scope != null, 'AppLocaleScope was not found in the widget tree.');

    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return locale != oldWidget.locale;
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
  late Locale _locale;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final savedLanguage = widget.services.preferences.getSelectedLanguage();

    _locale = Locale(savedLanguage == 'ur' ? 'ur' : 'en');
  }

  Future<void> _setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'ur') {
      return;
    }

    if (_locale == locale) {
      return;
    }

    await widget.services.preferences.setSelectedLanguage(locale.languageCode);

    if (!mounted) return;

    setState(() {
      _locale = locale;
    });
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
      child: AppLocaleScope(
        locale: _locale,
        setLocale: _setLocale,
        child: MaterialApp(
          title: 'PlantPulse',
          debugShowCheckedModeBanner: false,
          theme: buildPlantPulseTheme(),
          locale: _locale,
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
