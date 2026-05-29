# Ampex Mobile – designsystem

> **North star:** clean · seamless · intuitive · efficient — «nothing else compares»
>
> **Referanser:** Spotify Dark Mode (flyt, hierarki, ro, dyp bakgrunn), Airbnb (klarhet, luft, tillit), iOS HIG (gruppering, store titler, tydelig primærhandling)
>
> **Én standard** — Spotify Dark Mode tvinges på tvers av alle plattformer (iOS, Android, web) for et ekte premium-uttrykk.

---

## Farger (`app_colors.dart`)

| Token | Verdi | Bruk |
|-------|-------|------|
| `background` | `#000000` | Sidebakgrunn (Helt sort for dybde/OLED) |
| `surface` | `#121212` | Seksjoner / grouped sections (Spotify-kort) |
| `surfaceElevated` | `#181818` | Tab bar, nav bar |
| `label` | `#FFFFFF` | Primær tekst |
| `labelSecondary` | `#A7A7A7` | Sekundær tekst, ikoner |
| `labelTertiary` | `#727272` | Placeholder, chevrons |
| `labelPlaceholder` | `#535353` | Textfelt-hint |
| `accent` | `#3377FF` | Elektrisk blå primærknapp, lenker |
| `accentSoft` | `#263377FF` | Badge-bakgrunn, selected state |
| `separator` | `#1AFFFFFF` | Tynne, svært subtile skillelinjer |
| `destructive` | `#E91429` | Logg ut, slett, feil |
| `success` | `#1ED760` | Godkjent, synkronisert |
| `warning` | `#FFA42B` | Advarsel |

**Regler:**
- Dark mode er låst. Appen tilpasser seg ikke lys/mørk modus.
- Accent brukes **sparsomt** – knapper, aktiv tilstand, lenker.  
- Aldri fargede bakgrunner på kort. De forblir `surface`.
- Feil vises inline (`AmpexErrorBanner`), ikke SnackBar/Toast.

---

## Typografi (`app_typography.dart`)

| Token | Størrelse | Vekt | Bruk |
|-------|-----------|------|------|
| `largeTitle` | 34 | 700 | Skjermoverskrift (innlogging, startskjerm) |
| `title1` | 28 | 600 | Scrollbar-tittel (stor) |
| `title2` | 22 | 600 | Seksjonstittel |
| `headline` | 17 | 600 | Nav-tittel, liste-tittel, knapp-tekst |
| `body` | 17 | 400 | Brødtekst, feltinnhold |
| `callout` | 15 | 400 | Undertittel, sekundær tekst |
| `footnote` | 13 | 400 | Footers, hints, metadata |
| `caption` | 13 | 500 | Seksjonsoverskrifter (UPPERCASE) |
| `tabLabel` | 11 | 500 | Tab bar etiketter |

Ingen hardkodet font-familie — plattformstandard brukes (SF Pro på iOS, Roboto på Android, system-sans på web).

---

## Spacing (`app_spacing.dart`)

Basert på 4pt grid. Minimum touch target: **44pt** (iOS HIG, feltbruk i sollys).

| Token | Verdi | Bruk |
|-------|-------|------|
| `xs` | 4 | Ikongap, micro-spacing |
| `sm` | 8 | Mellom ikon og tekst |
| `md` | 16 | Standard sidepadding internt |
| `lg` | 24 | Mellom grupper |
| `xl` | 32 | Over/under stor tittel |
| `xxl` | 48 | Tomrom under sistelement |
| `screenH` | 20 | Horisontal sidepadding |
| `sectionGap` | 28 | Mellom `AmpexGroupedSection` |
| `rowV` | 13 | Radhoyde vertikal padding |
| `rowH` | 16 | Rad horisontal padding |
| `minTouch` | 44 | Minimum touch target |

---

## Avrunding (`app_radius.dart`)

| Token | Verdi | Bruk |
|-------|-------|------|
| `section` (12) | 12 | Grouped sections |
| `button` (12) | 12 | Knapper, tekstfelter |
| `chip` (8) | 8 | Badges, roller-chips |
| `sheet` (20) | 20 | Modaler, bottom sheets |

---

## Komponentbibliotek (`lib/core/widgets/`)

Features skal **aldri** bruke rå `Card`, `FilledButton`, eller `ListTile` direkte. Bruk disse:

### `AmpexBackdrop`
En helt sort bakgrunn som skaper basen for all dybde i appen. Brukes som rot-element i Scaffold.

### `AmpexGlass`
Frostet glassflate tilpasset dark mode (svak hvit border).

### `AmpexScaffold`
Sideskall med stor tittel, bouncing scroll, OfflineBanner. Alle listeskjermer bruker denne. Ligger oppå en `AmpexBackdrop`.
```dart
AmpexScaffold(
  title: 'Ordre',
  slivers: [SliverToBoxAdapter(child: ...)],
)
```

### `AmpexGroupedSection`
iOS Settings-seksjon tilpasset dark mode. Mørkegrå boks på sort bakgrunn.
```dart
AmpexGroupedSection(
  header: 'Arbeid',
  footer: 'Sist synket 12:34',
  children: [AmpexListRow(...)],
)
```

### `AmpexListRow`
Én rad. Ikon (farget firkant), tittel, undertittel, verdi/trailing, chevron.
```dart
AmpexListRow(
  leading: Icons.description_rounded,
  leadingColor: AppColors.accent,
  title: 'Ordre',
  subtitle: 'Oppfølging og dokumentasjon',
  onTap: () => context.go(Routes.orders),
)
```

### `AmpexPrimaryButton` / `AmpexTextButton`
Én primær per skjerm. `AmpexTextButton` for sekundære.
```dart
AmpexPrimaryButton(label: 'Logg inn', onPressed: _submit, isLoading: _loading)
AmpexTextButton(label: 'Avbryt', onPressed: () => context.pop())
AmpexTextButton(label: 'Slett', onPressed: _delete, destructive: true)
```

### `AmpexTextField`
Feltinnhold uten synlig ramme – `AmpexGroupedSection` er «rammen».
```dart
AmpexTextField(
  controller: _ctrl,
  hint: 'E-post',
  keyboardType: TextInputType.emailAddress,
  validator: (v) => v!.isEmpty ? 'Påkrevd' : null,
)
```

### `AmpexEmptyState`
Tom tilstand for lister. Ikon + tittel + undertekst + valgfri handling.
```dart
AmpexEmptyState(
  icon: CupertinoIcons.doc_text,
  title: 'Ingen ordre ennå',
  body: 'Ordreliste kommer i fase 1.',
)
```

### `AmpexErrorBanner`
Inline feilmelding. Brukes i skjema – ikke SnackBar.
```dart
if (_error != null)
  AmpexErrorBanner(message: _error!)
```

### `OfflineBanner`
Wrapper rundt innhold – viser diskret rød banner når offline.
```dart
OfflineBanner(child: myContent)
```

---

## Navigasjon

- **Router:** GoRouter med `StatefulShellRoute.indexedStack` (3 faner)
- **Tab shell:** `AppTabShell` – custom tab bar, konsistent på alle plattformer
- **Tilbake:** `context.pop()` alltid (ikke push tilbake)
- **Dype lenker:** `context.go(Routes.orders)` for tab-bytte

---

## Animasjon og overgang

| Kontekst | Stil |
|--------|------|
| Knapp-loading | `AnimatedSwitcher` 180ms |
| Sidenavn (large → small) | `AnimatedDefaultTextStyle` 150ms |
| Scroll | `BouncingScrollPhysics` overalt |
| Sideovergang (GoRouter) | Standard platform-transition |

Ingen splash, ingen fade-inn overalt, ingen parallax.

---

## Do / Don't

**✓ Do**
- Én `AmpexPrimaryButton` per skjerm
- Feil inline med `AmpexErrorBanner`
- Grouped sections for all listet innhold
- Test premiumfølelse på **iOS Simulator**, ikke bare web
- Store touch targets (≥ 44pt)

**✗ Don't**
- `Card` med `elevation` og ramme i feature-mapper
- Gradient bakgrunn
- Solid accent-bakgrunn på store flater
- Dark mode uten full dokumentasjon (lys modus prioriteres)
- Tre separate temaer per plattform

---

## Bygge videre (fase 1)

### Prosjektliste
```dart
AmpexScaffold(title: 'Prosjekter', slivers: [
  SliverToBoxAdapter(child: AmpexGroupedSection(
    children: projects.map((p) => AmpexListRow(
      leading: Icons.building_rounded,
      title: p.name,
      subtitle: p.address,
      onTap: () => context.go('/prosjekter/${p.id}'),
    )).toList(),
  )),
])
```

### Ordreliste
Samme mønster – bruk `AmpexListRow` med status som `value`-parameter (f.eks. `'Aktiv'`).

### PDF-viewer
Åpnes som ny route med `CupertinoPageRoute`-feeling. Laster lokalt (Drift/cache); viser `CircularProgressIndicator` på accent-farge mens den laster.

---

*Sist oppdatert: mai 2026 – fase 0/sprint 1 ferdig, fase 1 starter.*
