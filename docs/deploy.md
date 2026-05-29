# Deploy – Ampex Mobile

Dette repoet er **Flutter-mobilappen**, ikke [ampex.no](https://ampex.no) (Vercel). Deler **Supabase** med web, men har egen release-pipeline.

## Anbefalt strategi

| Kanal | Formål | Hvordan |
|-------|--------|---------|
| **iOS** | Primær produksjon (montører) | App Store via Xcode / Codemagic / GitHub Actions |
| **Android** | Primær produksjon | Google Play (AAB) |
| **Web** | Intern demo, testing, evt. PWA senere | Egen host (ikke Vercel for ampex.no) |

MVP-fokus: **native iOS + Android**. Web er nyttig for utvikling (`flutter run -d chrome`), ikke hovedproduktet.

## Miljøer

1. **Dev** – dagens Supabase-prosjekt, `.env` lokalt.
2. **Prod** – eget Supabase-prosjekt (eller branch) når dere går live; builds med `APP_ENV=prod` og prod-nøkler.

Secrets i CI/release: **`--dart-define`**, ikke `.env` i repo:

```bash
flutter build apk --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=https://<prod-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<prod-anon-key>

flutter build ipa --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Web (valgfritt):

```bash
flutter build web --release \
  --dart-define=APP_ENV=prod \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Output: `build/web/` → last opp til statisk host.

## Supabase Auth (viktig ved deploy)

I Supabase Dashboard → **Authentication → URL Configuration**:

- **Web host:** `https://<din-mobile-web-domene>` (f.eks. `https://app.ampex.no`)
- **Redirect URLs:** samme + `http://localhost:8080` for lokal dev
- **iOS:** bundle ID `no.ampex.mobile` + custom URL scheme hvis magic link
- **Android:** package name + SHA-256 for Google Sign-In senere

Bruk **anon key** i appen; aldri service role i klient.

## Web-hosting (hvis dere vil ha URL)

Ikke samme Vercel-prosjekt som ampex.no. Enkle valg:

1. **Cloudflare Pages** – `build/web`, SPA fallback til `index.html`
2. **Firebase Hosting** – god Flutter-web-støtte
3. **Netlify** – tilsvarende

Eget subdomene anbefales: f.eks. `app.ampex.no` eller `mobile.ampex.no` (DNS CNAME til host).

## App Store / Play Store (produksjon)

1. Apple Developer + Google Play Console-kontoer.
2. Signing: Xcode (iOS), keystore (Android).
3. Versjon i `pubspec.yaml` (`version: x.y.z+build`).
4. Første release: TestFlight (iOS) + internal testing (Android).
5. CI (valgfritt): [Codemagic](https://codemagic.io) eller GitHub Actions med `flutter build` + fastlane.

## GitHub (kildekode)

Push til `main` på [ampex-xlr8](https://github.com/stocktormod-design/ampex-xlr8). Automatisk **butikk-deploy** kobles på senere med workflow + secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY` i repo secrets).

## Sjekkliste før første prod-build

- [ ] Prod Supabase-prosjekt og RLS testet
- [ ] `APP_ENV=prod` og prod anon key i CI
- [ ] Redirect URLs oppdatert for alle plattformer
- [ ] Ikke committ `.env` eller service role
- [ ] App-ikoner / splash (senere)
