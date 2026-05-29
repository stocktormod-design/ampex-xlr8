# Ampex Mobile – designsystem

> **North star:** seamless · intuitive · efficient — premium feltverktøy, ikke «intern app».
>
> **Ampex er IKKE** Spotify, en sosial app, en mediaapp eller et generisk admin-dashboard.
> **Ampex ER** en mobil- og offline-first feltplattform for elektrofirmaer – brukt på byggeplass,
> i sollys, med skitne hender og hansker. Fart og klarhet foran alt.
>
> **Inspirasjon (ikke kopi):** iOS HIG (animasjon, luft, hierarki, store touch targets, sheets),
> Spotify (mørkt tema, sterkt hierarki, rolige kort, lite visuell støy), Linear (raske flyter,
> informasjonstetthet uten rot, profesjonell SaaS-følelse).
>
> **Regler:** Ikke gjenskap Spotify-skjermer. Ikke store svarte bokser som flyter midt på skjermen.
> Ikke bygg UI som en telefon-mockup inne i nettleseren. Ikke design rundt skjermbilder.
> **Dette designsystemet er sannheten.**

---

## Responsiv strategi (`app_breakpoints.dart`)

Samme komponenter overalt – kun **layouten** reflower per skjermstørrelse.

| Klasse | Bredde | Navigasjon | Innhold |
|--------|--------|------------|---------|
| `mobile` | 0–767 | Bunnlinje (`_BottomBar`) | 1 kolonne, full bredde |
| `tablet` | 768–1199 | Kompakt sidemeny (ikoner) | 3-kolonners rutenett |
| `desktop` | 1200+ | Utvidet sidemeny (ikon + tekst) | 4-kolonners rutenett, maks innholdsbredde |

```dart
context.deviceClass   // DeviceClass.mobile | tablet | desktop
context.isMobile      // bottom nav?
context.hasSideNav    // sidemeny fra og med tablet
context.gridColumns   // 2 | 3 | 4
```

Innhold får en **lesbar maks-bredde** (`AmpexScaffold.maxContentWidth`, default 1040) og fyller
bredden på mobil. Aldri en tynn boks som flyter midt på skjermen.

---

## Farger (`app_colors.dart`)

Mørkt, høykontrast (lesbart i sollys). Rolige nøytrale flater, én tydelig accent, eget statussystem.

| Token | Verdi | Bruk |
|-------|-------|------|
| `background` | `#0B0B0D` | Sidebakgrunn (dyp nøytral, ikke ren svart) |
| `surface` | `#161618` | Kort / grouped sections |
| `surfaceElevated` | `#1F1F23` | Hevede flater |
| `surfaceHighlight` | `#2A2A30` | Inputfelt, valgt nav, ikon-chip |
| `label` | `#F5F5F7` | Primær tekst |
| `labelSecondary` | `#A0A0AA` | Sekundær tekst |
| `labelTertiary` | `#6E6E78` | Chevrons, inaktive ikoner |
| `accent` | `#3B82F6` | Profesjonell elektrisk blå – knapp, lenke, aktiv |
| `border` | `#1FFFFFFF` | Hårfin kant på flater |
| `separator` | `#14FFFFFF` | Skillelinjer i lister |

**Statusfarger (ordre, avvik, fremdrift):**

| Token | Verdi | Betydning |
|-------|-------|-----------|
| `statusNeutral` | `#8A8A94` | Ikke startet |
| `statusActive` | `#3B82F6` | Pågår |
| `statusWaiting` | `#E8A317` | Venter / oppmerksomhet |
| `statusDone` | `#30A46C` | Ferdig |
| `destructive` | `#E5484D` | Slett, feil, åpne avvik |

**Regler:** Ett mørkt tema, låst (ingen lys/mørk-bytte). Accent brukes sparsomt. Kort er alltid
`surface` med hårfin `border` – aldri fargede flater. Feil vises inline (`AmpexErrorBanner`).

---

## Typografi (`app_typography.dart`)

Inter via `google_fonts` på alle plattformer (konsistent også på web).

| Token | Størrelse | Vekt | Bruk |
|-------|-----------|------|------|
| `largeTitle` | 32 | 700 | Skjermtittel / hilsen |
| `title1` | 26 | 600 | Nøkkeltall, stor verdi |
| `title2` | 20 | 600 | Seksjonstittel |
| `headline` | 16 | 600 | Rad-tittel, knapp, kort-label |
| `body` | 16 | 400 | Brødtekst, feltinnhold |
| `callout` | 14 | 400 | Undertittel, sekundær |
| `footnote` | 13 | 400 | Footers, metadata |
| `caption` | 12 | 500 | Badges, små etiketter |
| `tabLabel` | 11 | 500 | Nav-etiketter |

---

## Spacing & avrunding

4pt-grid. Minimum touch target **44pt**. Horisontal sidepadding: `screenH` (20) på mobil,
`xl` (32) på tablet/desktop. Avrunding: `section`/`button` 12, `chip` 8, `sheet` 20.

---

## Komponentbibliotek (`lib/core/widgets/`)

Features skal **aldri** bruke rå `Card`, `FilledButton` eller `ListTile`. Bruk disse:

- **`AmpexBackdrop`** – flat bakgrunn (`background`). Rot i alle skjermer. Ingen blur, ingen blobs.
- **`AmpexGlass`** – solid `surface`-flate med hårfin kant. **Ingen blur på innhold** (klarhet > effekt).
- **`AmpexBarBlur`** – tynt blur, **kun** for nav-/statusbar.
- **`AmpexScaffold`** – sideskall: stor tittel (+ valgfri `subtitle`/`trailing`), responsiv maks-bredde,
  bouncing scroll, `OfflineBanner`. Tar `slivers`.
- **`AmpexStatCard`** – nøkkeltall-kort (ikon, verdi, label) til dashboardet.
- **`AmpexModuleTile`** – modulkort; `coming: true` markerer ikke-bygde moduler med «Kommer»-badge.
- **`AmpexGroupedSection`** + **`AmpexListRow`** – iOS Settings-stil grupperte lister.
- **`AmpexPrimaryButton`** / **`AmpexTextButton`** – én primær per skjerm.
- **`AmpexTextField`**, **`AmpexEmptyState`**, **`AmpexErrorBanner`**, **`OfflineBanner`**.

---

## Navigasjon (`AppTabShell`)

Adaptivt skall over `StatefulShellRoute.indexedStack`. **Samme destinasjoner** på alle størrelser:

- **Mobil:** frostet bunnlinje (`AmpexBarBlur`), `extendBody` – innhold scroller under.
- **Tablet/desktop:** sidemeny til venstre (kompakt rail → utvidet med tekst + Ampex-merke).

Tilbake: `context.pop()`. Tab-bytte / dyplenke: `context.go(Routes.x)`.

---

## Dashboard = workspace (ikke meny)

Dashboardet skal svare på tre spørsmål:

1. **Hva jobber jeg med i dag?** → «I dag»: `AmpexStatCard`-rutenett (aktive ordre, prosjekter,
   oppgaver i dag, åpne avvik).
2. **Hva trenger oppmerksomhet?** → «Trenger oppmerksomhet»: liste eller ærlig «alt à jour»-kort.
3. **Hvor går jeg videre?** → «Moduler»: `AmpexModuleTile`-rutenett (bygde moduler navigerer,
   resten viser «Kommer»).

Ingen falske data: ubygde tellere viser `–` til backend-lister finnes.

---

## Do / Don't

**✓ Do** — én primærknapp per skjerm · inline feil · grouped sections for lister · store touch targets ·
test på iOS-simulator + faktiske breddepunkter, ikke bare smal web.

**✗ Don't** — telefon-mockup i nettleser · tynn flytende boks midt på skjerm · blur på innholdsflater ·
fargede kort-bakgrunner · `Card`/`elevation` i features · egne temaer per plattform.

---

*Sist oppdatert: mai 2026 – responsivt skall + workspace-dashboard, fase 0/1.*
