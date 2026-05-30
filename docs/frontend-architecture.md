# Ampex Frontend — to produkter, én plattform

> **Mental modell:** iOS og macOS — ikke «responsiv mobil».

```
        IKKE TENK                    TENK
        ─────────                    ────

   Samme app                    Ampex Mobile = iOS
        ↓                       Ampex Desktop = macOS
   Responsiv                         ↓
        ↓                      Samme: Supabase, modeller,
   Desktop                      providers, business logic
                                Forskjellig: all UI
```

## Ampex Mobile (arbeidsverktøyet)

**Brukeren står på byggeplassen.**

Spørsmål: *Hvor skal jeg? Hvilket rom? Hva mangler? Hvor er tegningen?*

| Egenskap | Valg |
|----------|------|
| Plattform | Native iOS, Android; smal nettleser |
| Navigasjon | Bottom tabs |
| Flyt | **Én ting av gangen** |
| Tegning | Fullskjerm → rom-sheet |
| Følelse | iPhone / Things 3 / Linear Mobile |

```
Prosjekt → Tegning → Rom → Oppgave
   (push)    (fullscreen)  (sheet)
```

## Ampex Desktop (kontrollsenteret)

**Prosjektleder på kontoret.**

Spørsmål: *Hvordan ligger prosjektet an? Hvor mange rom er ferdige? Hvem har oppgaver? Hvor er avvikene?*

| Egenskap | Valg |
|----------|------|
| Plattform | Web ≥768px, macOS, Windows |
| Navigasjon | Sidebar (collapsible) |
| Layout | **Split view, flere paneler** |
| Tegning | Canvas + inspector samtidig |
| Følelse | macOS / Linear / Notion |

```
┌─────────────────────────────────────────┐
│ Prosjektliste │ Tegning    │ Rom         │
│               │            │ Oppgaver    │
│               │            │ Fremdrift   │
└─────────────────────────────────────────┘
```

## Kode

### Produktvelger

```dart
context.isAmpexMobile   // Ampex Mobile
context.isAmpexDesktop  // Ampex Desktop
```

`lib/core/platform/app_product.dart` — native iOS/Android er **alltid** Mobile.

### Mappestruktur

```
lib/features/<modul>/
  shared/     # domain, data, providers
  mobile/     # Ampex Mobile UI
  desktop/    # Ampex Desktop UI
  presentation/  # adaptive entry points (router)
```

### Shell

| Produkt | Widget |
|---------|--------|
| Mobile | `MobileTabShell` |
| Desktop | `DesktopAppShell` |
| Router | `AdaptiveAppShell` |

### Prosjekter (eksempel)

| Route | Mobile | Desktop |
|-------|--------|---------|
| `/prosjekter` | Full liste | Split: liste + «Velg prosjekt» |
| `/prosjekter/:id` | Én kolonne | Tegning + inspector-panel |
| Tegning | `MobileDrawingWorkspace` | `CadWorkspace` |

`AdaptiveProjectsShell` + `ShellRoute` i GoRouter.

## Regler (absolutt)

1. **Aldri** skaler Mobile-layout til desktop-bredde.
2. **Aldri** press Desktop-sidebar inn på telefon.
3. Nye skjermer: `mobile/` + `desktop/` + tynn `adaptive_*` for router.
4. Del kun **logikk**, ikke **widgets**.
5. CAD-mørk flate kun på tegning — global app er lys og profesjonell.

## Delte lag

Supabase · Drift · Repositories · Riverpod providers · `DesignTokens`

Se også: [design-system.md](design-system.md), [architecture.md](architecture.md).
