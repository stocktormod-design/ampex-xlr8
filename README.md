# Ampex Mobile

Operativsystemet for elektrofirmaer — mobilapp (Flutter).

## Miljøvariabler

```bash
cp .env.example .env
```

| Nøkkel | Påkrevd | Beskrivelse |
|--------|---------|-------------|
| `APP_ENV` | Anbefalt | `dev` eller `prod` |
| `SUPABASE_URL` | Ja | `https://<ref>.supabase.co` |
| `SUPABASE_ANON_KEY` | Ja | Anon / publishable key fra Dashboard |
| `SUPABASE_PROJECT_REF` | Nei | Prosjekt-ref (dokumentasjon) |
| `S3_*` | Nei | Objektlagring når filer bygges |

Alternativ uten `.env` (CI/release):

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## Første gangs oppsett

```bash
cd ~/Projects/ampex-mobile
cp .env.example .env
# Rediger .env med dine Supabase-verdier

flutter pub get
dart run build_runner build
```

## Kjør appen

### Se UI uten Xcode (web – raskest)

```bash
cd ~/Projects/ampex-mobile
flutter run -d web-server --web-port=8080
```

Åpne **http://localhost:8080** i Brave/Chrome.

Med Brave som «Chrome» for Flutter:

```bash
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
flutter config --enable-web
flutter run -d chrome
```

### iOS (iPhone / simulator) – krever Xcode

```bash
# Én gang etter Xcode-install fra App Store:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo gem install cocoapods   # eller: brew install cocoapods

cd ~/Projects/ampex-mobile/ios && pod install && cd ..

# Start simulator og kjør:
open -a Simulator
flutter run -d ios
```

### Android – krever Android Studio + SDK

```bash
# Etter Android Studio er installert og emulator opprettet:
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d android
```

Fysisk Android-telefon (USB-debugging på):

```bash
flutter devices
flutter run -d <device-id>
```

### macOS desktop – krever full Xcode

```bash
flutter run -d macos
```

### Nyttige kommandoer

```bash
flutter devices              # tilgjengelige enheter
flutter doctor -v            # sjekk Xcode/Android/web
flutter test                 # tester
flutter analyze              # lint/analyse
flutter pub get              # avhengigheter
dart run build_runner build  # generer Drift (.g.dart)
```

### Release-bygg (senere)

```bash
# Android APK
flutter build apk --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# iOS (krever Xcode + signing)
flutter build ipa --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## Dokumentasjon

- [docs/vision.md](docs/vision.md)
- [docs/scope.md](docs/scope.md)
- [docs/architecture.md](docs/architecture.md)
- [docs/database.md](docs/database.md)

## Arkitektur (kort)

- **State:** Riverpod
- **Routing:** GoRouter
- **Backend:** Supabase (delt med web)
- **Offline:** Drift (SQLite)
- **Package ID:** `no.ampex.mobile`
