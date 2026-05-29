# Ampex – visjon

## Hva er Ampex?

Ampex er operativsystemet for elektrofirmaer. Målet er å samle service, prosjekter, tegninger, dokumentasjon, timer, materiell, oppgaver og fremdrift i én premium plattform.

Ampex skal **ikke** være et regnskapssystem. Ampex skal levere **grunnlag** til regnskapssystemer (eksport, strukturerte data, sporbarhet).

## North star (produkt)

Ampex skal oppleves slik at firmaer tenker at **ingenting annet kan sammenlignes** — ikke fordi vi har flest funksjoner, men fordi bruken er:

| | |
|--|--|
| **Seamless** | Alt henger sammen; innlogging → jobb uten unødvendige steg; data og filer føles alltid tilgjengelige |
| **Intuitive** | Forståelig uten kurs; norsk; forutsigbar navigasjon; tydelig hvem du er og hvilket firma du jobber for |
| **Efficient** | Færrest mulig trykk; riktig informasjon på rett sted; teknisk kompleksitet (synk, offline) skjules |

## Kjerneverdier

| Verdi | Betydning |
|-------|-----------|
| Mobile-first | Feltbrukere først; kontor kan bruke web |
| Offline-first | Ordre, prosjekter, PDF, oppgaver og mer fungerer uten nett |
| Multi-tenant | Én bedrift = én tenant; full dataisolasjon |
| Premium | Rask, intuitiv, profesjonell UX – ikke «intern app»-følelse |
| Feature-first | Moduler som vertikale snitt, ikke lag-kake med tomme mapper |
| Langsiktig | Enkel arkitektur som kan vokse uten omskriving |

## Plattform

- **Web/desktop:** mer avansert (tegning, planlegging, publisering, flere verktøy).
- **Mobil:** enklere felt-UX — lese, registrere, PDF offline; ikke duplisere full tegneverktøy-kraft på liten skjerm.

## Målgruppe

Elektrikere og ledere i felt:

- Montør
- Serviceelektriker
- Formann på byggeplass
- Prosjektleder (felt + planlegging)

Kontorbrukere trenger ikke full offline i v1.

## Produktområder (høynivå)

- **Ordre** – service, kunde, dokumentasjon, timer, materiell
- **Prosjekter** – tegninger, bygg/plan/rom, oppgaver, fremdrift
- **Delt** – innboks, varsler, avvik, brukere
- **Støtte** – timer, lager, levende prosedyrer, kursbevis (etter hvert)

## Ikke-mål (produkt)

- Regnskap, lønn, fakturering
- ERP-erstatning (Tripletex m.m.)
- AI-generering av rom/oppgaver i MVP

## Suksess for Ampex Mobile (v1)

Feltbruker kan:

1. Logge inn med e-post og passord
2. Se dashboard med inngang til Ordre og Prosjekter
3. Åpne ordre- og prosjektliste (mot delt Supabase-backend)
4. Jobbe offline med lesing, oppretting og redigering (synk ved tilkobling)
5. Åpne prosjekt-PDF fra cache etter at filen er åpnet én gang

## Språk

Kun **norsk** i v1. Ingen i18n-arbeid før det er produktkrav.
