# Rozdělení práce — týmový plán (vyvážená verze)

Cíl: mít rozdělení, které je smysluplné, navazující a přibližně stejně náročné pro všechny 3 studenty. Frontend zůstává společná práce na konci.

## Shrnutí rolí
- Student 1: API vrstva + kontrakty + validační/chybová vrstva + část testů
- Student 2: ORM + business logika + oprávnění + část autentizace
- Student 3: databáze + migrace + seed + integrace + část autentizace
- Všichni: Frontend (společně, na konci)

## Odhad zátěže (backend)
- Student 1: ~33 %
- Student 2: ~34 %
- Student 3: ~33 %

---

## Timeline implementace (pořadí a návaznost)
1. Dny 0–1: společný kick-off
- sjednotit názvosloví endpointů, DTO a status kódů
- připravit branch strategii, Definition of Done, code style

2. Dny 1–3: databázový a doménový základ
- Student 2: entity + vztahy + repository návrh
- Student 3: připojení DB, migrace, start seed skriptů
- Student 1: návrh API kontraktů (request/response), validace, error model

3. Dny 3–6: první funkční backend vertikála
- Student 2: service metody pro todolists + tasks
- Student 1: controllery pro todolists + tasks (napojení na service)
- Student 3: integrační test prostředí, data fixtures, smoke testy

4. Dny 6–8: autentizace a role
- Student 2: bezpečnostní logika (role pravidla v service)
- Student 3: JWT integrace, filtry a environment konfigurace
- Student 1: auth endpointy + chybové scénáře + API dokumentace auth flow

5. Dny 8–10: stabilizace backendu
- Student 1: controller testy + API dokumentace + Postman kolekce
- Student 2: business unit testy a edge-case validace
- Student 3: integrační testy, seed finalizace, ladění propojení

6. Dny 10–14: frontend (společně)
- jednoduché UI nad stabilním API

---

## Student 1 — API & Controllers (rovnoměrně rozšířeno)
### Hlavní odpovědnost
HTTP vrstva, DTO kontrakty, validace vstupů, jednotný error handling, API dokumentace.

### TODO
- Implementovat endpointy podle `project-spec.md`:
  - `/api/auth/*`, `/api/users/me`, `/api/todolists/*`, `/api/tasks/*`, comments, attachments.
- Vytvořit DTO request/response pro všechny endpointy.
- Přidat Bean Validation (`@NotBlank`, `@Email`, `@Size`, atd.).
- Zavést globální `@ControllerAdvice` pro jednotné chyby.
- Připravit OpenAPI/Postman kolekci + ukázkové payloady.
- Napsat controller testy (pozitivní + negativní scénáře).

### Deliverables
- Stabilní REST API vrstva.
- Dokumentované API kontrakty.
- Sada testů pro controller vrstvu.

---

## Student 2 — Business logika & ORM
### Hlavní odpovědnost
Doménové mapování, repository vrstva, service logika, role pravidla a konzistence dat.

### TODO
- Z `supabase_schema.sql` domapovat JPA entity a relace.
- Připravit/rozšířit repository dotazy pro hlavní use-cases.
- Implementovat service metody:
  - `createTodolist`, `addUserToTodolist`, `removeUserFromTodolist`
  - `createTask`, `assignUserToTask`, `unassignUserFromTask`, `updateTaskStatus`, `deleteTask`
- Zapracovat business validace:
  - existence entit, duplicity, povolené stavy tasku, oprávnění podle role.
- Přidat transakční hranice (`@Transactional`) a zápis do `audit_log`.
- Podílet se na auth logice: mapování `auth_id` -> `AppUser` a role vyhodnocení v service.

### Deliverables
- Kompletní service vrstva s business pravidly.
- ORM model odpovídající DB.
- Unit testy pro kritické service scénáře.

---

## Student 3 — DB + testy + integrace
### Hlavní odpovědnost
Databázová infrastruktura, migrace, seed data, integrační testy, běhová stabilita.

### TODO
- Připravit databázový běh projektu (lokální Postgres/Supabase).
- Zvolit a nakonfigurovat migrace (Flyway/Liquibase) nebo jasný SQL import workflow.
- Připravit seed data:
  - role, test user, ukázkový list, tasky, vazby.
- Dotáhnout integrační konfiguraci ORM a environment proměnné.
- Implementovat integrační testy:
  - repository + service + security flow.
- Ladit propojení backendu s DB (nullable, constraints, enumy, timezone).
- Podílet se na auth technické části: JWT konfigurace, filtry, test scénáře tokenů.

### Deliverables
- Reprodukovatelné DB prostředí.
- Seed a integrační testy s návodem spuštění.
- Stabilní propojení backendu s databází.

---

## Frontend — společná práce (všichni, beze změny)
### Cíl
Jednoduché UI pro login, práci se seznamy a úkoly, komentáře a přílohy.

### TODO
- Vybrat jednoduchý stack (doporučeno React + Vite).
- Implementovat obrazovky:
  - Login
  - Todolist list/detail
  - Task detail + změna stavu
  - Comment form
  - Attachment upload
- Napojit UI na hotové API.
- Ověřit základní uživatelské scénáře end-to-end.

---

## Pravidla spolupráce
- Každý student vlastní svůj backend modul, ale PR review dělá vždy aspoň 1 další člen.
- Denní krátký sync (15–20 min): blokery, změny v kontraktech, rizika.
- Změna API kontraktu je možná jen po informování všech.
- Každý merge musí obsahovat:
  - testy pro změněnou logiku
  - krátký changelog v popisu PR

---

## Milníky
- M1 (dny 0–3): entity + DB + API kontrakty připravené
- M2 (dny 3–6): todolist/task vertikála funkční
- M3 (dny 6–10): auth + testy + integrační stabilita
- M4 (dny 10–14): společný frontend + final bugfix + prezentace
