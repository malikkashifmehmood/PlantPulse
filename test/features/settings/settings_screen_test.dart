import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/features/settings/settings_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await AppServices.create();
  });

  testWidgets('loads saved Urdu language at startup', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;

    await services.preferences.setSelectedLanguage('ur');
    await tester.pumpWidget(PlantPulseApp(services: services));

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.locale, const Locale('ur'));

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('loads English when no language is saved', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(PlantPulseApp(services: services));

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.locale, const Locale('en'));

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('changes language from Settings and persists Urdu', (
    tester,
  ) async {
    var locale = const Locale('en');

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return AppLocaleScope(
            locale: locale,
            setLocale: (value) async {
              await services.preferences.setSelectedLanguage(
                value.languageCode,
              );
              setState(() => locale = value);
            },
            child: MaterialApp(
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ur'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SettingsScreen(),
            ),
          );
        },
      ),
    );

    expect(find.text('Settings'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Urdu').last);
    await tester.pumpAndSettle();

    expect(locale, const Locale('ur'));
    expect(services.preferences.getSelectedLanguage(), 'ur');
    expect(find.text('ترتیبات'), findsOneWidget);
  });
}