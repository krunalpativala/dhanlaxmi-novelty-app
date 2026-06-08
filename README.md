# dhanlaxmi-novelty-app

Flutter wholesale order app with Firebase.

## Local setup

This repository does not include Firebase config files, signing keys, APKs, logs,
or local machine files.

Before running/building locally, generate or restore:

- `android/app/google-services.json`
- `lib/firebase_options.dart`
- `android/key.properties` and the release keystore, only for release builds

For the price visibility password, pass a build-time value:

```sh
flutter run --dart-define=PRICE_VISIBILITY_PASSWORD=your-password
```
