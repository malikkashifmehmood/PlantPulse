import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final services = await AppServices.create();

  runApp(PlantPulseApp(services: services));
}
