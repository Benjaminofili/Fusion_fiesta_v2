# FusionFiesta

FusionFiesta is a role-aware Flutter application that helps college stakeholders discover, manage, and analyze campus events. The app is structured to support three primary personas (students, organizers, administrators) while sharing a consistent UI kit, routing layer, and mockable data services.

## Project Structure

```
lib/
 ├─ app/                # MaterialApp + router + DI setup
 ├─ core/               # constants, theme, widgets, services, utils
 ├─ data/               # models + repository contracts
 ├─ features/           # role- or domain-specific UI modules
 ├─ mock/               # in-memory repository implementations
 └─ l10n/               # localization entry point
```

## Tech Decisions

- **Navigation**: `go_router` with a role-aware `MainNavigationShell`
- **State/Data**: `get_it` for dependency injection, repository abstractions backed by mock data
- **UI Kit**: shared widgets (event cards, stats tiles, search, upload pickers, QR display, notification badge)
- **Integrations**: placeholders for Google Maps, QR scanning, notifications, and media/document uploads

## Getting Started

1. Install Flutter 3.x and run `flutter pub get`.
2. Launch the mock experience: `flutter run`.
3. Use the default credentials on the login screen to explore each role (update user role via mock repositories when needed).

## Next Steps

- Swap mock repositories with real backend adapters (Firebase, Supabase alternative, etc.).
- Flesh out feature blocs/state management per module.
- Expand localization files in `lib/l10n`.
- Add widget and bloc tests under `test/`.