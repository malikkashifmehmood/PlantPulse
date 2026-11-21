import 'package:shared_preferences/shared_preferences.dart';

import '../features/analysis/data/prediction_repository.dart';
import '../features/diagnosis/data/diagnosis_repository.dart';
import '../features/expert/data/plant_assistant_repository.dart';
import '../features/expert/data/plant_assistant_service.dart';
import '../features/plants/data/plant_repository.dart';
import '../features/treatment/data/treatment_progress_repository.dart';
import 'network/plantpulse_api.dart';
import 'security/secure_storage_service.dart';
import 'security/security_service.dart';
import 'storage/app_preferences_repository.dart';
import 'storage/local_storage_service.dart';

class AppServices {
  AppServices._({
    required this.secureStorage,
    required this.localStorage,
    required this.preferences,
    required this.security,
    required this.plants,
    required this.diagnoses,
    required this.treatmentProgress,
    required this.plantPulseApi,
    required this.predictions,
    required this.plantAssistantRepository,
    required this.plantAssistantService,
  });

  final SecureStorageService secureStorage;
  final LocalStorageService localStorage;
  final AppPreferencesRepository preferences;
  final SecurityService security;
  final PlantRepository plants;
  final DiagnosisRepository diagnoses;
  final TreatmentProgressRepository treatmentProgress;
  final PlantPulseApi plantPulseApi;
  final PredictionRepository predictions;
  final PlantAssistantRepository plantAssistantRepository;
  final PlantAssistantService plantAssistantService;

  static Future<AppServices> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final secureStorage = SecureStorageService();
    final localStorage = LocalStorageService(sharedPreferences);
    final preferences = AppPreferencesRepository(localStorage);
    final security = SecurityService(secureStorage: secureStorage);

    final plants = PlantRepository(localStorage);
    final diagnoses = DiagnosisRepository(localStorage);
    final treatmentProgress = TreatmentProgressRepository(localStorage);

    final plantPulseApi = PlantPulseApi();
    final predictions = PredictionRepository(plantPulseApi);

    final plantAssistantRepository = PlantAssistantRepository(localStorage);
    final plantAssistantService = PlantAssistantService();

    return AppServices._(
      secureStorage: secureStorage,
      localStorage: localStorage,
      preferences: preferences,
      security: security,
      plants: plants,
      diagnoses: diagnoses,
      treatmentProgress: treatmentProgress,
      plantPulseApi: plantPulseApi,
      predictions: predictions,
      plantAssistantRepository: plantAssistantRepository,
      plantAssistantService: plantAssistantService,
    );
  }
}
