# PlantPulse UI Screen Map

Source: supplied PlantPulse Project Documentation.

| Screen | Flutter file | Main purpose |
|---|---|---|
| 01 Splash | splash_screen.dart | Model/loading introduction |
| 02 Onboarding | onboarding_screen.dart | Diagnose crop diseases |
| 03 Onboarding | onboarding_screen.dart | How it works |
| 04 Onboarding | onboarding_screen.dart | Works offline |
| 05 Sign In/Create Account | auth_screen.dart | Account access |
| 06 Home Dashboard | home_screen.dart | Garden overview |
| 07 Scan Camera | scan_screen.dart | Leaf capture |
| 08 Analyzing | analysis_screen.dart | Analysis progress |
| 09 Low Confidence/Retake | low_confidence_screen.dart | Safe failure state |
| 10 Diagnosis Result | diagnosis_screen.dart | Diagnosis and confidence |
| 11 Treatment Plan | treatment_screen.dart | Care actions |
| 12 My Plants | plants_screen.dart | Plant records |
| 13 Plant Detail | plant_detail_screen.dart | Plant timeline/status |
| 14 Scan History | history_screen.dart | Scan history |
| 15 Ask an Expert | expert_screen.dart | Support chat |
| 16 Alerts | alerts_screen.dart | Warnings/reminders |
| 17 Profile | profile_screen.dart | Account/resources |
| 18 Settings | settings_screen.dart | Privacy/security/app controls |

## UI/security boundary

The current implementation intentionally uses mock/local UI state.

Production security work must later address:
- credential handling
- authentication and authorization
- secure communication
- privacy and permission handling
- input/output validation
- secure storage
- cryptography
- dependency/supply-chain controls
- release configuration
- binary protection
