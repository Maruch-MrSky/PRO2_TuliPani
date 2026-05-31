# Rozdělení práce — týmový plán

Cíl: mít jasné, navazující a spravedlivě rozdělené úkoly pro 3 studenty; backend bude připraven před společným frontendem.

## Souhrnný stav (checklist)

- [x] Vytvořit `rozdeleni-prace.md`
- [ ] Student 1 — API & Controllers (probíhá)
- [ ] Student 2 — Business & ORM
- [ ] Student 3 — DB, testy, integrace
- [ ] Frontend — společná práce
- [ ] Dokumentace & nasazení

## Shrnutí rolí
- Student 1: HTTP vrstva, DTO, validace, jednotné zpracování chyb, controller testy, API dokumentace
- Student 2: JPA entity, repository, service logika, transakce, audit
- Student 3: databáze, migrace, seed, integrační testy, runtime konfigurace

---

## Timeline (pořadí a návaznost)

1) Dny 0–1 — Kick-off
- [x] sjednotit názvosloví endpointů, DTO a status kódů
- [x] připravit branch strategii, Definition of Done, code style

2) Dny 1–3 — DB & doména
- [ ] Student 2: entity + vztahy + repository návrh
- [ ] Student 3: připojení DB, migrace, seed skripty
- [x] Student 1: návrh API kontraktů (request/response), validace, error model

3) Dny 3–6 — První backend vertikála
- [ ] Student 2: service metody pro todolists + tasks
- [x] Student 1: controllery pro todolists + tasks (bez business logiky)
- [ ] Student 3: integrační test prostředí, fixtures, smoke testy

4) Dny 6–8 — Autentizace a role
- [ ] Student 2: bezpečnostní logika v service (role pravidla)
- [ ] Student 3: JWT integrace, filtry, env konfigurace
- [ ] Student 1: auth endpointy, chybové scénáře, API dokumentace auth flow

5) Dny 8–10 — Stabilizace
- [ ] Student 1: controller testy, API dokumentace, Postman kolekce
- [ ] Student 2: business unit testy a edge-case validace
- [ ] Student 3: integrační testy, seed finalizace, ladění propojení

6) Dny 10–14 — Frontend (společně)
- jednoduché UI: login, todolisty, tasky, komentáře, přílohy

---

### Timeline checklist

- [x] Dny 0–1: Kick-off
- [x] Dny 1–3: DB & doména (návrhy)
- [ ] Dny 3–6: první backend vertikála
- [ ] Dny 6–8: autentizace a role
- [ ] Dny 8–10: stabilizace
- [ ] Dny 10–14: frontend


## Student 1 — API & Controllers
### Hlavní odpovědnost
HTTP vrstva, DTO kontrakty, validace vstupů, jednotné zpracování chyb, controller testy a API dokumentace.

### TODO (Student 1)
- [ ] Implementovat všechny endpointy podle `project-spec.md`
- [x] Vytvořit DTO request/response (část implementována)
- [ ] Přidat Bean Validation (`@NotBlank`, `@Email`, `@Size`)
- [x] Zavést globální `@ControllerAdvice` pro jednotné chyby
- [ ] Připravit OpenAPI / Postman kolekci
- [x] Napsat základní controller testy (MockMvc)

### Deliverables
- Stabilní REST API vrstva (kontrakty)
- Jednotné chybové odpovědi a validace
- Sada controller testů

---

## Student 2 — Business logika & ORM
### Hlavní odpovědnost
Doménové mapování (JPA), repository vrstva, service logika, role pravidla, transakce a audit.

### TODO (Student 2)
- [ ] Namapovat JPA entity a relace ze `supabase_schema.sql`
- [ ] Připravit repository dotazy pro hlavní use-cases
- [ ] Implementovat service metody (např. `createTodolist`, `addUserToTodolist`)
- [ ] Zapracovat business validace a transakce
- [ ] Zajistit zápis do `audit_log`
- [ ] Napsat unit testy pro service

### Stav implementace (aktuálně - Student 2)
- [x] Namapovat JPA entity a relace (entities present in `src/main/java/.../domain/entity`)
- [x] Připravit repository dotazy pro hlavní use-cases (additional helpers added)
- [x] Implementovat základní service metody:
	- [x] `createTodolist`, `listTodolists`
	- [x] `createTask`, `getTask`
	- [x] `assignUserToTask`, `unassignUserFromTask` (task-level assignment)
	- [ ] `addUserToTodolist`, `removeUserFromTodolist` (todolist-level membership — in progress)
	- [ ] `updateTaskStatus`, `deleteTask` (pending)
- [x] Zajistit zápis do `audit_log` pro vytvoření úkolu a přiřazení/odebrání uživatele
- [~] Jednotkové testy: `TodolistService` tests present; `TaskService` tests added for create/get/assign/unassign; more tests pending for status/delete

Poznámka: během práce byly přidány ochrany proti duplicitám a základní role checks pro přiřazování/odebíraní uživatelů.

### Deliverables
- Kompletní service vrstva s business pravidly
- ORM model odpovídající DB
- Jednotkové testy kritických scénářů

---

## Student 3 — DB, testy a integrace
### Hlavní odpovědnost
Databázová infrastruktura, migrace, seed data, integrační testy, runtime konfigurace.

### TODO (Student 3)
- [ ] Připravit lokální DB běh (Postgres / Supabase)
- [ ] Vybrat a nakonfigurovat migrace (Flyway/Liquibase) nebo SQL import
- [ ] Připravit seed data (role, test user, ukázkový list)
- [ ] Nastavit integrační testy (Testcontainers / fixtures)
- [ ] Ladit propojení backendu s DB
- [ ] Implementovat JWT integraci a test scénáře

### Deliverables
- Reprodukovatelné DB prostředí a seed
- Integrační testy a návod ke spuštění
- Stabilní propojení backendu s databází

---

## Frontend — společná práce (všichni)
### Cíl
Jednoduché UI pro login, práci se seznamy a úkoly, komentáře a přílohy.

### TODO (Frontend)
- [ ] Vybrat stack (doporučeno React + Vite)
- [ ] Implementovat obrazovky: Login, Todolist list/detail, Task detail, Comment form, Attachment upload
- [ ] Napojit UI na hotové API
- [ ] Ověřit základní uživatelské scénáře end-to-end

---

## Pravidla spolupráce
- Každý student vlastní svůj backend modul, PR review vždy minimálně 1 další člen
- Denní krátký sync (15–20 min): blokery, změny v kontraktech, rizika
- Změna API kontraktu jen po informování všech členů a souhlasném review
- Každý merge musí obsahovat testy pro změněnou logiku a krátký changelog v popisu PR

---

## Milníky
- M1 (dny 0–3): entity + DB + API kontrakty připravené
- M2 (dny 3–6): todolist/task vertikála funkční
- M3 (dny 6–10): auth + testy + integrační stabilita
- M4 (dny 10–14): společný frontend + final bugfix + prezentace
