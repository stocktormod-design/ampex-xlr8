# Ampex Mobile – arkitektur

## Stack

| Lag | Teknologi |
|-----|-----------|
| UI | Flutter (Material 3) |
| State | Riverpod |
| Routing | GoRouter |
| Auth | Supabase Auth |
| API / DB | Supabase (PostgreSQL + PostgREST + RLS) |
| Offline DB | Drift (SQLite) |
| Filer | S3-kompatibel lagring (metadata i Postgres, bytes i bucket) |
| Språk | Norsk (`nb`) |

## Systemkontekst

```
┌─────────────────────────────────────────────────────────┐
│                    Ampex Mobile (Flutter)                │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ Presentation│→ │  Riverpod    │→ │  Repositories   │ │
│  └─────────────┘  └──────────────┘  └────────┬────────┘ │
│                                               │          │
│                    ┌──────────────────────────┼──────┐   │
│                    ▼                          ▼      ▼   │
│              ┌──────────┐              ┌──────────┐ S3   │
│              │  Drift   │              │ Supabase │ API  │
│              │ (SQLite) │              │  client  │      │
│              └──────────┘              └────┬─────┘      │
└─────────────────────────────────────────────┼────────────┘
                                              ▼
                                    ┌─────────────────┐
                                    │ Supabase Cloud   │
                                    │ (delt med web)   │
                                    └─────────────────┘
```

Web og mobil deler **samme** Supabase-prosjekt per miljø. Mobil introduserer ikke parallelle skjemaer uten migrasjon i `supabase/migrations` (koordinert med web-team).

## Mappestruktur

```
lib/
├── main.dart
├── app.dart
├── core/           # config, theme, platform, routing, db, sync, auth
└── features/
    ├── auth/
    ├── shell/
    │   ├── mobile/presentation/
    │   ├── desktop/presentation/
    │   └── shared/presentation/
    ├── orders/
    └── projects/
```

### To produkter (Mobile vs Desktop)

**Ikke** responsiv skalering — **to** UI-produkter over samme backend.

| | Ampex Mobile | Ampex Desktop |
|--|--------------|---------------|
| Analogi | iOS | macOS |
| Rolle | Arbeidsverktøy på plass | Kontrollsenter på kontor |

Se **[frontend-architecture.md](frontend-architecture.md)**.

Per feature:

```
features/projects/
├── shared/         # domain, data, providers (barrel)
├── mobile/         # field UI
├── desktop/        # office UI
└── presentation/   # adaptive entry + shared providers
```

## Lagregler

1. **Presentation** kjenner ikke Supabase- eller SQL-detaljer direkte.
2. **Repositories** er grensen mot Drift og Supabase.
3. **Lesing:** Drift først → UI; bakgrunnsoppdatering fra Supabase når online.
4. **Skriving:** Drift + rad i `sync_outbox` → synkarbeider ved tilkobling.
5. **Konflikt v1:** Last write wins (`updated_at` på server).

## Autentisering

- Supabase Auth: e-post + passord
- Session lagres av `supabase_flutter`
- GoRouter `redirect` sender uautentiserte brukere til `/login`
- `profiles` rad kobles til `auth.users` (eksisterende web-mønster)
- Tenant: `profiles.company_id` → all datafiltrering via RLS

## Offline og synk (v1-design)

### Lokale tabeller (grunnmur)

| Tabell | Formål |
|--------|--------|
| `sync_outbox` | Ventende mutasjoner (JSON payload) |
| `sync_state` | Sist synket per entitet/type |
| `cached_files` | PDF/bilder på disk + metadata |

### Flyt

1. Bruker endrer data offline → skriv til Drift + outbox.
2. App detekterer nett (`connectivity_plus`) → `SyncEngine` prosesserer outbox.
3. Suksess → oppdater `sync_state`, fjern outbox-rad.
4. Feil → behold outbox, vis status (ingen CRDT).

### PDF

- Ved åpning: last ned til app-lagring, registrer i `cached_files`.
- Ved offline: les fra lokal fil.
- Ingen bulk-prefetch av alle tegninger.

## Multi-tenant

- Tenant = `companies.id`
- Alle forretningstabeller har `company_id`
- RLS på Supabase håndhever isolasjon
- Mobil sender aldri `company_id` fra klient uten at policy tillater det (bruker JWT + profil)

## Miljøer

| Miljø | Bruk |
|-------|------|
| `dev` | Lokal utvikling, `.env` med dev-nøkler |
| `prod` | App Store / Play Store builds |

Staging legges til senere med egen Supabase-ref og build flavor.

## Konfigurasjon

- `.env` (gitignored): `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Aldri commit service role eller S3-hemmeligheter
- CI: `--dart-define` eller secrets store

## Testing (retning)

- Enhetstester på repositories og synk-logikk
- Widget-tester på shell og auth
- Integrasjon mot Supabase local eller dev-prosjekt

## Avhengigheter (bevisst utelatt i grunnmur)

- `riverpod_generator` – manuelle providers inntil behov
- Annotasjon på bilder, LiDAR, GPS SDK
- EDI-klienter
