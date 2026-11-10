SMART NOTE App
This is a cross-platform mobile application built using Flutter, designed for educational purposes to demonstrate modern best practices in app architecture and development. The app implements Clean Architecture, ensuring clear separation of concerns and maintainability across multiple feature layers.

🧠 Key Features:
Modular and scalable project structure following Clean Architecture

State management with BLoC (Business Logic Component)

Persistent local storage with Hive

Type-safe networking with Retrofit

Dependency injection and service abstraction for testability and flexibility

⚙️ Technologies Used:
Flutter & Dart

BLoC for predictable state management

Hive for lightweight and fast local storage

Retrofit for structured API communication

Dio as the underlying HTTP client

Equatable, GetIt, and other clean-code utilities

📚 Purpose:
This project serves as a learning tool for developers interested in mastering advanced Flutter patterns, writing testable and maintainable code, and building scalable mobile applications.

## Running

```bash
flutter pub get
flutter run                      # uses the production API
flutter run --dart-define=API_BASE_URL=http://localhost:5000/   # any other server (keep the trailing /)
```

The same `--dart-define` works for `flutter build apk|ipa|web`.

## Tests

```bash
flutter test
```

## Code generation

Models and the Retrofit client are generated. After changing a `@JsonSerializable` model or `api_service.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Notes for developers

- **Login token** is stored in secure storage (Keychain / Keystore), not in Hive.
- **Request logging** runs in debug builds only, and hides passwords, tokens and the `Authorization` header.
- **Errors** are mapped to user-friendly messages in one place (`lib/data/repository/api_call.dart`, `lib/infra/network/api_error.dart`).
  `status: false` responses are treated as errors even with HTTP 200.
- **Session expiry**: any 401 from a non-public endpoint logs the user out and returns to the login screen.
- **Offline**: the notebook list and note pages are cached; without a connection the last saved copy is shown with an offline banner.
  Search results and edits need a connection. The cache is cleared on logout.
