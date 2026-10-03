# PlantPulse UI Foundation

PlantPulse is a Flutter UI implementation based on the supplied PlantPulse Project Documentation.

The documentation defines this flow:

Splash -> Onboarding -> Sign In -> Home -> Scan -> Analysis -> Diagnosis -> Treatment -> Plants -> History -> Expert -> Alerts -> Profile -> Settings

This repository is the UI foundation only. It uses local mock data and Flutter SDK widgets so the visual layer can be built and tested before adding authentication, camera, AI inference, backend services, secure storage, notifications, and other production functionality.

## Included

- 18 documented screens/states
- Material 3 theme
- PlantPulse visual design system
- Responsive phone-oriented layouts
- Bottom navigation for main application areas
- Scan, analysis, low-confidence, diagnosis and treatment states
- Plant records, history, expert, alerts, profile and settings
- Empty/loading/error/confirmation UI patterns
- No API keys, credentials, or secrets

## Run

```bash
flutter pub get
flutter analyze
flutter run
```

## Git phase

This repository represents the UI foundation milestone.

Suggested commit:

```bash
git add .
git commit -m "feat: add PlantPulse complete UI foundation"
git push
```

Do not commit API keys, passwords, signing files, production certificates, or local environment secrets.

## Next implementation order

1. Replace mock navigation with application routing/state management.
2. Add secure authentication.
3. Add secure local storage.
4. Add camera capture and permission handling.
5. Add on-device model integration.
6. Add diagnosis confidence/error handling.
7. Add backend/API communication over TLS.
8. Add plant/history persistence.
9. Add notifications.
10. Perform OWASP Mobile Top 10 hardening and testing.
