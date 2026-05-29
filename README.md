# Ampex Mobile

Operativsystemet for elektrofirmaer — mobilapp (Flutter).

## Krav

- Flutter 3.44+ (stable)
- Xcode / Android Studio for enhetsbygg

## Kom i gang

1. Kopier miljøvariabler:

   ```bash
   cp .env.example .env
   ```

   Fyll inn `SUPABASE_URL` og `SUPABASE_ANON_KEY` fra Supabase Dashboard (dev).

2. Installer avhengigheter og generer Drift-kode:

   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Kjør appen:

   ```bash
   flutter run
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

## Faser

| Fase | Innhold |
|------|---------|
| 0 (nå) | Grunnmur, auth, shell, docs |
| 1 | Ordre/prosjekt liste + detalj, PDF-cache, synk |

Se `docs/scope.md` for full master scope.
