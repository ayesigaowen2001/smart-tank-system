# smart_tank_control

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/to/state-management-sample).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).

## What the app does (concise)

- User authentication: users sign in (email/password).
- Dashboard: authenticated users view a list of tanks and a detail view per tank.
- Tank monitoring: each tank has sensors (e.g., water level, temperature) and time-series readings.
- Actions: view current sensor values, view historical readings, and navigate from list -> detail.
- Settings: user can change UI preferences (ThemeMode is persisted via SettingsController).
- Basic sample items/views are present for navigation and feature scaffolding.

## Suggested API and auth

- Auth: use token-based auth (JWT) with HTTPS.
- Header: Authorization: Bearer <token>

Endpoints (minimal):

- POST /api/auth/login
  - Request: { "email": "...", "password": "..." }
  - Response: { "token": "...", "user": {User} }

- POST /api/auth/register
  - Request: { "email","password","name" }
  - Response: { "token", "user" }

- GET /api/tanks
  - Response: [ {Tank} ]

- POST /api/tanks
  - Request: { "name","location","metadata" }
  - Response: {Tank}

- GET /api/tanks/{tankId}
  - Response: {Tank with sensors and latest readings}

- GET /api/tanks/{tankId}/readings?sensorId=&from=&to=&limit=
  - Response: [ {Reading} ]

- POST /api/tanks/{tankId}/readings
  - Request: { "sensorId", "timestamp", "value" }
  - Response: {Reading}

- GET /api/users/me
  - Response: {User}

- GET /api/settings (per user)
  - Response: {Settings}
- PUT /api/settings
  - Request: {Settings}
  - Response: {Settings}

## Core data models (JSON schema sketches)

- User
  - {
    "id": "uuid",
    "email": "string",
    "name": "string",
    "createdAt": "ISO8601",
    }

- Tank
  - {
    "id": "uuid",
    "ownerId": "uuid",
    "name": "string",
    "location": "string",
    "metadata": { "notes": "...", ... },
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
    }

- Sensor
  - {
    "id": "uuid",
    "tankId": "uuid",
    "type": "string", // e.g., "level", "temperature"
    "unit": "string", // e.g., "cm", "°C"
    "meta": { ... }
    }

- Reading
  - {
    "id": "uuid",
    "tankId": "uuid",
    "sensorId": "uuid",
    "timestamp": "ISO8601",
    "value": number,
    "metadata": { ... }
    }

- Settings
  - {
    "userId": "uuid",
    "themeMode": "light|dark|system",
    // add other user prefs here
    }

## Minimal DB considerations

- Tables/collections:
  - users, tanks, sensors, readings, settings
- Indexes:
  - readings: index on (tankId, sensorId, timestamp) for efficient time-range queries
- Retention:
  - consider TTL or downsampling for high-frequency readings

## Notes for the frontend

- Authenticate and store JWT securely (use flutter_secure_storage).
- Use endpoints above to populate the List and Detail views.
- Persist settings locally and sync to /api/settings when available.
- Provide a small endpoint or websocket for real-time pushes if you plan live updates.

## Generating localization (AppLocalizations)

The project expects generated localization classes (package:flutter_gen/gen_l10n/app_localizations.dart). To create them:

1. Create the ARB directory and file locally:
   - Path: lib/l10n/app_en.arb
   - Content: see the sample below.

2. Run the generation commands:
   - flutter pub get
   - flutter gen-l10n

3. If the analyzer still reports missing generated files:
   - flutter clean
   - flutter pub get
   - flutter gen-l10n
   - Restart your IDE.

Sample minimal ARB (copy to lib/l10n/app_en.arb)

```json
{
  "@@locale": "en",
  "appTitle": "Smart Tank Control",
  "@appTitle": {
    "description": "Title for the application"
  },
  "loginTitle": "Smart Tank Login",
  "@loginTitle": {
    "description": "Login screen title"
  },
  "loginButton": "Login",
  "@loginButton": {
    "description": "Text for the login button"
  },
  "loginFailed": "Login failed",
  "@loginFailed": {
    "description": "Message shown when login fails"
  }
}
```

Notes

- After running flutter gen-l10n the file package:flutter_gen/gen_l10n/app_localizations.dart will be generated and the import in lib/src/app.dart will resolve.
- If your Flutter SDK does not support embedding l10n config in pubspec.yaml, using the gen-l10n command and placing ARB files into lib/l10n is the recommended approach.

## Build & install APK via adb

Prerequisites:

- USB debugging enabled on device (Settings → Developer options).
- adb available on your PATH (Android SDK platform-tools).
- Device connected via USB and authorized.

1. Verify device is connected:

   ```
   adb devices
   ```

2. Build an APK (from project root):
   - Debug:
     ```
     flutter build apk --debug
     ```
     APK path: build/app/outputs/flutter-apk/app-debug.apk
   - Release:
     ```
     flutter build apk --release
     ```
     APK path: build/app/outputs/flutter-apk/app-release.apk

3. Install the APK:
   - Install (replace path as needed):
     ```
     adb install -r build/app/outputs/flutter-apk/app-debug.apk
     ```
   - Target a specific device:
     ```
     adb -s <device-id> install -r build/app/outputs/flutter-apk/app-release.apk
     ```

4. Launch the app (replace <PACKAGE_NAME>):
   - Quick launch:
     ```
     adb shell monkey -p <PACKAGE_NAME> -c android.intent.category.LAUNCHER 1
     ```
   - Or explicit start (need main activity):
     ```
     adb shell am start -n <PACKAGE_NAME>/<MAIN_ACTIVITY>
     ```

5. Helpful commands:
   - Uninstall existing app:
     ```
     adb uninstall <PACKAGE_NAME>
     ```
   - View device logs:
     ```
     adb logcat
     ```
   - Restart adb server:
     ```
     adb kill-server && adb start-server
     ```

Finding your package name:

- Check android/app/src/main/AndroidManifest.xml 'package' attribute or android/app/build.gradle 'applicationId'.

Notes:

- Use `flutter install` as an alternative — it builds and deploys automatically to connected device(s).
- For release installs, ensure the app is signed (see Flutter docs on app signing).

## Linux desktop build prerequisites

If you plan to run the app on Linux (flutter run --flavor linux), install required build tools and a C++ compiler:

Ubuntu / Debian:

```bash
sudo apt update
sudo apt install -y build-essential clang cmake ninja-build pkg-config libgtk-3-dev
# or minimal (use g++):
sudo apt install -y build-essential
export CXX=g++
# add to ~/.bashrc to persist:
echo 'export CXX=g++' >> ~/.bashrc
```

Fedora:

```bash
sudo dnf install -y @development-tools clang cmake ninja-build pkgconfig gtk3-devel
```

Verify:

```bash
clang++ --version   # or g++ --version
cmake --version
```

Then rebuild:

```bash
flutter clean
flutter pub get
flutter run
```
