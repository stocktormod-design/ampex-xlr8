# Ampex – scope

Dette dokumentet beskriver **hele produktscope** (master) og hva som gjelder for **Ampex Mobile** i hver fase.

## Låste beslutninger (mobil)

| Område | Beslutning |
|--------|------------|
| Repo | `ampex-mobile` |
| App-navn | Ampex |
| Package ID | `no.ampex.mobile` |
| Språk | Norsk |
| Auth | E-post + passord (Supabase Auth) |
| Tenant | Én bedrift = én tenant (`company_id` i DB) |
| Roller MVP | Admin, Prosjektleder, Montør |
| Offline | Les, opprett, rediger; synk når nett er tilbake |
| Konflikt v1 | Last write wins |
| PDF | Cache ved åpning; ikke forhåndslaste hele firmaet |
| Bilder v1 | Kamera + galleri; ikke annotasjon |
| Miljø | `dev` + `prod` (staging senere) |
| Backend | Delt Supabase med eksisterende web |

---

## Fase 0 – Grunnmur (denne økten)

- Prosjektstruktur, dokumentasjon, tema, routing
- Supabase Auth + klient
- Drift-database med synk-/cache-tabeller (skjelett)
- App-shell: innlogging, dashboard, tomme modulinnganger
- **Ikke:** forretnings-CRUD, PDF-viewer, synkmotor med entiteter

---

## Fase 1 – Tynt MVP (mobil)

### Dashboard

Snarveier / navigasjon til:

- Ordre
- Prosjekter

(Øvrige moduler fra master scope kan vises som «kommer snart» eller skjules.)

### Ordre

- Liste
- Detalj (lesing; redigering der backend/RLS tillater)

Felter (master): kunde, adresse, kontakt, status, ansvarlig, timer, materiell, bilder, dokumentasjon, notater.

Status (mål): Ikke startet, Pågår, Venter, Ferdig (kartlegges mot eksisterende `orders.status` enum).

### Prosjekter

- Liste
- Detalj
- PDF: visning + lokal cache etter første åpning

Struktur (mål): Prosjekt → Bygg → Plan → Rom. Rom er kjerne for oppgaver, fremdrift, bilder, avvik, dokumentasjon.

### Offline (v1)

Må fungere uten nett for fase 1-entiteter:

- Ordre (liste/detalj)
- Prosjekter (liste/detalj)
- PDF (åpnede filer)
- Grunnleggende redigering med synk ved tilkobling

---

## Master scope – moduler (referanse)

### Dashboard-moduler (full plattform)

Ordre, Prosjekter, Oppgaver, Innboks, Timer, Lager, Dokumentasjon.

### Ordremodul (full)

Kunde, adresse, kontaktperson, status, ansvarlig, timer, materiell, bilder, dokumentasjon, notater.

**Dokumentasjon (generering):** Risikovurdering, samsvarserklæring, sluttkontroll, kursfortegnelse, utstyrsdokumentasjon – Nelfo-kompatibelt.

### Prosjektmodul (full)

Tegninger (PDF, versjoner, zoom, pan, offline), bygg, plan, rom, oppgaver, fremdrift.

### Fremdrift (full)

Per fag: Brann, Elkraft, Tele/Data, Automasjon, Belysning. Filtrering på bygg, plan, rom, fag, subfag.

### Oppgaver (full)

Knyttes til prosjekt, bygg, plan, rom eller ordre. Tildeling til brukere.

### Innboks (full)

Varsler: ny oppgave, ordre, prosjekt, avvik, scan-forespørsel, manglende dokumentasjon.

### Avvik (full)

Bilder, ansvarlig, status, prioritet, historikk.

### Timer (full)

Registrering på ordre/prosjekt/oppgave; start/stopp; manuell; daglig oversikt; eksport Excel/CSV/PDF.

### Materiell (full)

På ordre, prosjekt, oppgave, rom – innpris, utpris, antall, leverandør.

### Lager (full)

Hovedlager + billager per bil; flytting lager ↔ bil ↔ prosjekt.

### EDI (full – senere)

Ahlsell, Solar, Onninen, Elektroskandia – søk, lagerstatus, bestilling, prisforespørsel.

### Kursbevis (full – senere)

Kurs, sertifikater, utløpsdato, påminnelser.

### Levende prosedyrer (full – senere)

Prosedyrer, revisjoner, historikk, forbedringsmeldinger, avvikskobling.

### LiDAR (full – senere)

Scan, punktsky, GLB på rom; oppgaver «Ta LiDAR scan».

### GPS / Teltonika FMB920 (full – senere)

Kjørebok, turlogg, kobling tur ↔ ordre.

### Smart timer (full – senere)

Dagsoppsummering fra GPS + oppgaver + ordre; bruker godkjenner forslag.

---

## Ikke i MVP (mobil eller plattform)

- Regnskap, lønn, fakturering
- ERP-erstatning
- AI-generering av rom/oppgaver
- SSO (Google/Microsoft)
- Avdelinger under tenant (Bergen/Oslo/Trondheim) – datamodell forberedes, ikke bygges nå
- Annotasjon på bilder
- Avansert konflikthåndtering (CRDT)

---

## Roller (referanse)

| Rolle | Mobil-relevant |
|-------|----------------|
| **Admin** | Firma, brukere, lager, prosjekter, ordre, prosedyrer |
| **Prosjektleder** | Prosjekter, ordre, oppgaver, fremdrift, rom |
| **Montør** | Se oppgaver, timer, materiell, fremdrift, bilder, dokumentasjon |

Tilgang håndheves via Supabase RLS og `profiles.role` (kartlegges mot eksisterende enum).
