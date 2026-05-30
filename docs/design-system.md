# Ampex – designsystem

> **Én plattform, to produkter** — som iOS og macOS. Samme tokens, forskjellige layouts.

## Ampex Mobile

- Lys, høy kontrast (sollys)
- Min. **48pt** touch
- Bottom navigation
- Fullskjerm-tegning, bottom tools, hvite sheets
- Spørsmål designet svarer på: *hvor, hvilket rom, hva mangler*

## Ampex Desktop

- Lys, profesjonell SaaS
- Min. **40pt** click targets
- Sidebar + split views
- Paneler for rom, oppgaver, fremdrift, avvik
- Spørsmål designet svarer på: *status, fremdrift, ansvar, avvik*

## Tokens (`design_tokens.dart`)

| Token | Verdi | Bruk |
|-------|-------|------|
| `background` | `#F5F6F8` | Sidebakgrunn |
| `surface` | `#FFFFFF` | Kort, paneler |
| `accent` | `#2563EB` | Primær handling |
| `textPrimary` | `#111827` | Titler |

## API

```dart
context.isAmpexMobile
context.isAmpexDesktop
AppTheme.forProduct(AmpexProduct.mobile | desktop)
```

## Komponenter

`AmpexScaffold`, `AmpexGroupedSection`, `AmpexListRow`, `AmpexModuleTile` — felles byggeklosser, **forskjellig sammensetting** per produkt.

## Unngå

- Responsiv «stretch»
- Mørk global app (unntatt CAD-tegning)
- Neon / crypto-dashboard
- Desktop-tabeller på telefon

*Sist oppdatert: mai 2026 — Mobile / Desktop produktmodell.*
