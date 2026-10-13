# GEMINI.md - appmovil261

## Project Overview
`appmovil261` is a Flutter mobile application built with a feature-driven Clean Architecture. It uses Supabase as its backend service (for authentication and database) and the BLoC pattern for state management.

### Key Technologies
- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK `^3.10.8`)
- **Backend:** [Supabase](https://supabase.com/) (`supabase_flutter`)
- **State Management:** [BLoC](https://pub.dev/packages/flutter_bloc) (`flutter_bloc`)
- **Linting:** `flutter_lints`

## Project Architecture
The project follows a feature-based architecture within the `lib/` directory:

```text
lib/
├── features/
│   ├── auth/          # Common authentication logic
│   │   ├── data/      # Repository implementations and data sources
│   │   └── domain/    # Entities, repository interfaces, and usecases
│   └── signup/        # Signup feature
│       └── ui/        # Screens, widgets, and BLoCs specific to signup
├── widgets/           # Reusable UI components
└── main.dart          # Application entry point and Supabase initialization
```

- **Domain Layer:** Contains the business logic, usecases, and repository interfaces.
- **Data Layer:** Contains the implementation of repository interfaces and interactions with external data sources (Supabase).
- **UI Layer:** Contains Flutter widgets (Screens/Components) and BLoCs for managing the state of the UI.

## Building and Running
The standard Flutter development commands apply to this project:

- **Fetch Dependencies:**
  ```bash
  flutter pub get
  ```
- **Run the Application:**
  ```bash
  flutter run
  ```
- **Run Tests:**
  ```bash
  flutter test
  ```
- **Analyze Code (Linting):**
  ```bash
  flutter analyze
  ```
- **Build APK (Android):**
  ```bash
  flutter build apk
  ```
- **Build iOS (macOS only):**
  ```bash
  flutter build ios
  ```

## Development Conventions
1. **Feature-Based Structure:** When adding a new feature, create a new directory under `lib/features/` with the standard `domain`, `data`, and `ui` sub-directories.
2. **State Management:** Use `flutter_bloc` for all complex state management. BLoCs should be placed in the `ui/bloc` folder of their respective features.
3. **Repository Pattern:** Define repository interfaces in the `domain` layer and their implementations in the `data` layer.
4. **Usecases:** Encapsulate business logic into usecase classes within the `domain` layer.
5. **Linting:** Follow the rules defined in `analysis_options.yaml`. Ensure `flutter analyze` passes before committing.
6. **Initialization:** Supabase is initialized in `main.dart`. Ensure you have the correct `url` and `anonKey` for your environment.

## Key Files
- `lib/main.dart`: Entry point, Supabase initialization, and core app configuration.
- `pubspec.yaml`: Project dependencies and metadata.
- `analysis_options.yaml`: Static analysis and linting rules.
- `lib/features/auth/domain/usecases/signup_usecase.dart`: Example of the usecase pattern.
- `lib/features/signup/ui/bloc/signup_bloc.dart`: Example of the BLoC implementation.
