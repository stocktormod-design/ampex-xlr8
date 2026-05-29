# Ampex – database

## Oversikt

| Lag | Teknologi | Eier |
|-----|-----------|------|
| Server | PostgreSQL (Supabase) | Delt web + mobil |
| Klient | SQLite via Drift | Kun mobil |

Mobil **speiler** ikke hele skjemaet lokalt i grunnmur. Lokale tabeller starter med synk og fil-cache; entitetstabeller legges til per feature i fase 1.

## Tenant

- Tabell: `public.companies`
- Foreign key på forretningsdata: `company_id` (uuid)
- Én bedrift = én tenant i v1

## Eksisterende Supabase-tabeller (utdrag)

Mobil kobles til **eksisterende** backend. Relevante tabeller:

| Tabell | Modul |
|--------|--------|
| `companies` | Tenant |
| `profiles` | Bruker + rolle + `company_id` |
| `orders`, `order_customers`, `order_hours`, `order_materials`, `order_photos`, `order_documentation`, `order_risk_assessments` | Ordre |
| `projects`, `project_assignments`, `project_activity_log` | Prosjekt |
| `drawings`, `drawing_rooms`, `drawing_room_status`, `drawing_layers`, `drawing_tasks`, `drawing_activity_log` | Tegninger / rom |
| `inbox_messages`, `installer_inbox_items` | Innboks |
| `deviations`, `deviation_events` | Avvik |
| `work_sessions`, `location_samples` | Arbeidsdag / GPS (senere mobil) |
| `warehouses`, `warehouse_items`, … | Lager |
| `protocols`, `protocol_acknowledgements` | Prosedyrer |
| `course_certificates` | Kursbevis |
| `room_lidar_scans` | LiDAR (senere) |

**Merk:** Rom/struktur i web kan mappes via `drawing_rooms` og relaterte tabeller inntil dedikert bygg/plan/rom-hierarki er fullstendig modellert.

## Roller

`profiles.role` (USER-DEFINED enum) – kartlegg mot produktroller:

| Produkt | Forventet DB-tilgang via RLS |
|---------|------------------------------|
| Admin | Bred administrasjon innen `company_id` |
| Prosjektleder | Prosjekter, ordre, oppgaver, fremdrift |
| Montør | Tildelte oppgaver, registreringer |

Detaljerte policies ligger i Supabase; mobil forutsetter at RLS allerede er korrekt for web.

## Ordre – status (mål vs DB)

Produktstatus (master):

- Ikke startet
- Pågår
- Venter
- Ferdig

Eksisterende `orders.status` enum må kartlegges i feature-arbeid (ikke endres i grunnmur uten avtale med web).

## Drift – lokalt skjema (grunnmur)

```sql
-- Konseptuelt (genereres av Drift)

sync_outbox (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,  -- insert | update | delete
  payload TEXT NOT NULL,    -- JSON
  created_at INTEGER NOT NULL,
  retry_count INTEGER NOT NULL DEFAULT 0
)

sync_state (
  entity_type TEXT PRIMARY KEY,
  last_synced_at INTEGER,
  cursor TEXT
)

cached_files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  remote_path TEXT NOT NULL UNIQUE,
  local_path TEXT NOT NULL,
  mime_type TEXT,
  entity_type TEXT,
  entity_id TEXT,
  opened_at INTEGER NOT NULL,
  size_bytes INTEGER
)
```

## Synk-strategi (v1)

1. **Last write wins** på `updated_at` (server) ved konflikt.
2. Outbox prosesseres FIFO per entitetstype.
3. Ingen tombstone-synk for sletting uten eksplisitt `delete` i outbox.

## Fil-lagring

- **Metadata:** Postgres (f.eks. `drawings`, `order_photos`)
- **Bytes:** S3-kompatibel bucket (URL/signert tilgang fra Supabase eller direkte)
- **Mobil:** `cached_files` + filsystem under app-dokumenter

## Migrasjoner

- Server: `supabase/migrations/` (koordinert med web – ikke dupliser i mobil-repo uten prosess)
- Klient: Drift `schemaVersion` i `app_database.dart`

## Indekser og ytelse (retning)

- Alle mobil-spørringer filtrerer på `company_id` (via RLS, ikke klient-filter alene)
- Paginering på lister (ordre, prosjekter)
- PDF: stream + cache, ikke load hele bucket

## Fremtidige entiteter (master – ikke migrert i grunnmur)

- Billager per kjøretøy
- EDI `supplier_product_maps`
- Smart timer / GPS korrelasjon
- Levende prosedyrer revisjonskjede

Se `scope.md` for tidsplan.
