# Ampex Mobile – designsystem

> **North star:** clean · seamless · intuitive · efficient — «nothing else compares»
>
> **Referanser:** Spotify (flyt, hierarki, ro), Airbnb (klarhet, luft, tillit), iOS HIG (gruppering, store titler, tydelig primærhandling)
>
> **Én standard** — samme tokens, samme widgets, alle plattformer (iOS, Android, web).

---

## Farger (`app_colors.dart`)

| Token | Verdi | Bruk |
|-------|-------|------|
| `background` | `#F2F2F7` | Sidebakgrunn |
| `surface` | `#FFFFFF` | Seksjoner / grouped sections |
| `surfaceElevated` | `#FAFAFC` | Tab bar, nav bar |
| `label` | `#0D0D0D` | Primær tekst |
| `labelSecondary` | `#6B6B70` | Sekundær tekst, ikoner |
| `labelTertiary` | `#AEAEB2` | Placeholder, chevrons |
| `labelPlaceholder` | `#C7C7CC` | Textfelt-hint |
| `accent` | `#0A66C2` | Knapper, aktiv tab, lenker |
| `accentSoft` | `#E8F0FB` | Badge-bakgrunn, selected state |
| `separator` | `#E5E5EA` | Tynne skillelinjer (0.5pt) |
| `destructive` | `#D93025` | Logg ut, slett, feil |
| `success` | `#1E8A4C` | Godkjent, synkronisert |
| `warning` | `#F59E0B` | Advarsel |

**Regler:**
- Accent brukes **sparsomt** – knapper, aktiv tilstand, lenker.  
- Aldri gradient. Aldri solid blå bakgrunn.  
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

### `AmpexScaffold`
Sideskall med stor tittel, bouncing scroll, OfflineBanner. Alle listeskjermer bruker denne.
```dart
AmpexScaffold(
  title: 'Ordre',
  slivers: [SliverToBoxAdapter(child: ...)],
)
```

### `AmpexGroupedSection`
iOS Settings-seksjon. Hvit avrundet boks på grå bakgrunn.
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
