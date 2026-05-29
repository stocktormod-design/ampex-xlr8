# Prompt: Ampex Mobile – UI-designstandard (én helhet, alle plattformer)

Kopier alt under **«PROMPT START»** til Claude Sonnet 4.6 (eller tilsvarende). Legg ved 2–3 skjermbilder fra Spotify/Airbnb hvis du kan.

---

## PROMPT START

Du er en senior product designer + Flutter-utvikler som skal etablere **én visuell og interaksjonsmessig standard** for **Ampex Mobile** – en premium, offline-first feltapp for norske elektrofirmaer.

### Produktkontekst

- **App:** Ampex Mobile (`~/Projects/ampex-mobile`, pakke `ampex_mobile`, bundle `no.ampex.mobile`)
- **Stack (ikke endre uten å si fra):** Flutter, Riverpod, GoRouter, Supabase Auth, Drift (kommer), norsk UI (`nb`)
- **Backend:** Supabase (delt med Ampex web) – **ikke** bygg ny backend
- **Fase nå:** Auth + shell fungerer. Neste er lister/PDF – men **denne oppgaven er kun design-system + polering av eksisterende skjermer**
- **North star:** *clean, seamless, intuitive, efficient* – «nothing else compares»

### Design-intensjon (viktigst)

Tenk **UI som én helhet på tvers av iOS, Android og web** – ikke tre separate design.

- **Referansekvalitet (følelse, ikke kopi):** [Spotify](https://open.spotify.com) (flyt, hierarki, mørk/lys balanse, micro-interactions), [Airbnb](https://www.airbnb.com) (klarhet, tillit, luft, lister som «glir»)
- **Strukturell disiplin:** Apple iOS HIG (grouped content, large titles, tydelig primærhandling, minimal støy)
- **Ikke:** Material «default», gradient-login, tunge kort med rammer, blå stripe overalt, «web-app på telefon»
- **Ja:** Ett designspråk implementert med **plattformtilpassede widgets** der det gir bedre UX (Cupertino på iOS, Material 3 med samme tokens på Android/web) – **samme spacing, farger, typografi, komponent-API**

### Prinsipper (må reflekteres i kode)

1. **Seamless** – få steg, ingen unødvendige modaler, forutsigbar navigasjon, skeleton/loading som føles rolig (ikke hakkete spinners overalt)
2. **Hierarchy** – én primær handling per skjerm; sekundær som tekst/ghost; destruktiv tydelig men ikke skrikende
3. **Density** – feltapp: lesbar i sollys, store touch targets (min 44pt), men ikke «barne-app» store tomrom
4. **Grouped surfaces** – lister i seksjoner (Settings/Spotify-stil), ikke løse Material Cards med border
5. **Motion** – korte, naturlige overganger (200–300ms), `BouncingScrollPhysics` der det passer, ingen flashy animasjoner
6. **Brand** – Ampex er profesjonell B2B; accent brukes sparsomt (knapper, aktiv tab, lenker) – ikke hele skjermen blå

### Teknisk ramme (Flutter)

- Opprett/foren **design tokens** i `lib/core/theme/`:
  - `app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart`, `app_theme.dart`
- Opprett **gjenbrukbare komponenter** i `lib/core/widgets/` (maks ~8 stk, ikke over-abstract):
  - f.eks. `AmpexScaffold`, `AmpexGroupedSection`, `AmpexListRow`, `AmpexPrimaryButton`, `AmpexTextField`, `AmpexTabShell`, `AmpexEmptyState`, `AmpexErrorBanner`
- **Én komponent-API** – samme widgets på iOS/Android/web; bruk `Theme.of` / `Platform.isIOS` kun inni komponenten ved behov
- Behold **GoRouter** + auth-flow; refaktorer kun: login, tab shell, hjem, placeholder ordre/prosjekter
- **Språk:** all brukertekst på norsk
- Kjør `flutter analyze` og `flutter test` – ingen nye features (ingen Supabase-queries for lister ennå)

### Skjermer som skal poleres (scope)

| Skjerm | Mål |
|--------|-----|
| Oppstart / Supabase-kobling | Rolig, merkevare, tydelig feil |
| Login | Spotify-lignende ro: grouped fields, én primærknapp, ingen gradient |
| Hjem (dashboard) | Personlig hilsen, firma, rolle, snarveier – ikke «modulkort-landingsside» |
| Tab shell | 3 faner: Hjem, Ordre, Prosjekter – føles native på alle plattformer |
| Placeholder Ordre/Prosjekter | Pen empty state som lover kvalitet (fase 1 kommer) |

### Leveranser (i denne rekkefølgen)

1. **`docs/design-system.md`** (1–2 sider): farger, type scale, spacing, komponenter, do/don’t, med korte Spotify/Airbnb-referanser
2. **Token-filer + tema** som matcher dokumentet
3. **Komponentbibliotek** (widgets over)
4. **Refaktorerte skjermer** som bruker kun disse komponentene
5. Kort **«hvordan vi bygger videre»**-seksjon i design-system (f.eks. prosjektliste, PDF-viewer skal følge samme list row)

### Suksesskriterier (sjekkliste)

- [ ] Samme app på **web (localhost)**, **iOS Simulator** og **Android emulator** føles som **samme produkt**
- [ ] Ingen rå `Card`/`FilledButton` direkte i feature-mapper – kun design-system widgets
- [ ] Login + hjem ser **premium** ut uten å ligne en admin-dashboard-template
- [ ] `flutter analyze` grønn, eksisterende tester passerer
- [ ] Ingen nye dependencies uten begrunnelse

### Ikke gjør

- Ikke implementer ordreliste, prosjektliste, PDF eller sync i denne oppgaven
- Ikke bytt state management, routing eller Supabase-oppsett
- Ikke tre separate temaer for ios/android/web
- Ikke legg til dark mode med mindre du også dokumenterer det fullt ut (lys modus først er OK)
- Ikke «redesign» ved å legge til flere farger, skygger og gradients

### Eksisterende filer (start her)

Les før du skriver kode:

- `lib/core/theme/`
- `lib/core/widgets/`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/shell/presentation/`
- `lib/features/orders/presentation/orders_placeholder_screen.dart`
- `lib/features/projects/presentation/projects_placeholder_screen.dart`
- `lib/app.dart`, `lib/core/routing/app_router.dart`

### Output-format fra deg

1. Oppsummer designvalg (5–8 bullets)
2. Implementer filer (full kode, ikke pseudokode)
3. List hva brukeren skal kjøre for å se resultatet:
   ```bash
   cd ~/Projects/ampex-mobile
   flutter pub get
   flutter run -d chrome          # rask sjekk
   flutter run -d ios             # sannhetskilde for «premium»
   ```
4. 3 konkrete forbedringsforslag for **fase 1** (lister/PDF) som følger samme system

---

## PROMPT SLUTT

---

## Tips når du bruker prompten

1. **Vedlegg:** 1 skjermbilde Spotify (f.eks. bibliotek/liste), 1 fra Airbnb (søk/liste), 1 fra dagens Ampex hvis du vil vise «bort fra dette».
2. **Modell:** Claude Sonnet 4.6 thinking eller Opus for første foundation-pass; deretter billigere modell for features som *følger* `design-system.md`.
3. **Review på iPhone:** Web er OK for rask sjekk – **godkjenning skjer på iOS Simulator**.
4. Etter leveranse: commit med melding `design: establish cross-platform UI system (Spotify/Airbnb/iOS)`.

## Valgfri tilleggsetning (lim inn under PROMPT)

```
Ampex accent: bruk #007AFF (iOS system blue) eller en dempet navy #1B3A5C – velg én og dokumenter.
Typografi: ikke hardkod SF på web; bruk platform default (.AppleSystemUIFont / Roboto) med samme scale.
```
