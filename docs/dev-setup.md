# Utvikleroppsett (dev)

## Testbruker for Ampex Mobile

Opprett en dedikert mobil-testbruker i **Supabase dev-prosjektet** (samme som web).

### 1. Opprett bruker i Auth

1. Åpne [Supabase Dashboard](https://supabase.com/dashboard) → prosjektet ditt.
2. **Authentication** → **Users** → **Add user**.
3. Velg **Create new user**.
4. Fyll inn:
   - **E-post:** f.eks. `mobil-dev@din-bedrift.no`
   - **Passord:** sterkt passord (lagres lokalt, ikke i git)
   - Huk av **Auto Confirm User** (slipper e-postbekreftelse i dev).

### 2. Koble til firma (profiles)

Kopier brukerens **UUID** fra Auth. Kjør i SQL Editor (tilpass `company_id` og e-post):

```sql
-- Velg company_id fra: select id, name from companies;
insert into public.profiles (id, company_id, role, full_name)
values (
  'BRUKER-UUID-FRA-AUTH',
  '8ed68cad-d47a-45fb-9bbb-2941bcd9daaa',  -- eksempel: Aqila
  'montor',
  'Mobil Dev'
)
on conflict (id) do update set
  company_id = excluded.company_id,
  role = excluded.role,
  full_name = excluded.full_name;
```

Gyldige roller (`app_role`): `admin`, `prosjektleder`, `montor`, `installator`, `owner`, `apprentice`, `baas`, `regnskapsforer`.

### 3. Logg inn i appen

```bash
cd ~/Projects/ampex-mobile
cp .env.example .env   # hvis ikke gjort
flutter run -d web-server --web-port=8080
```

Bruk e-post og passord fra steg 1.

### Alternativ: eksisterende web-bruker

Hvis du allerede har innlogging på Ampex web, kan du bruke **samme e-post og passord** i mobil — forutsatt at `profiles`-rad finnes.

## Feilsøking

| Problem | Løsning |
|---------|---------|
| «Fant ingen brukerprofil» | Mangler rad i `profiles` — kjør SQL over |
| «Feil e-post eller passord» | Sjekk Auth-bruker eller passord |
| Tomt firmanavn | `company_id` peker ikke på gyldig `companies`-rad |
