# Backend TODO

## Základní kostra
- [x] založit Spring Boot projekt
- [x] připravit entity pro minimálně 10 modelů podle `supabase_schema.sql`
- [x] připravit repository vrstvu
- [x] připravit controller, service a security kostru
- [x] přidat základní testy

## Další práce
- [ ] doplnit skutečné mapování relací mezi tabulkami
- [ ] napojit autentizaci na `auth_id` a JWT
- [ ] implementovat registraci a login
- [ ] přidat validace a duplicitní kontroly
- [ ] implementovat createTodolist, addUserToTodolist a removeUserFromTodolist
- [ ] implementovat createTask, assignUserToTask, unassignUserFromTask, updateTaskStatus a deleteTask
- [ ] přidat CRUD pro komentáře a přílohy
- [ ] přidat napojení na Supabase databázi a produkční konfiguraci
- [ ] rozšířit unit testy pro service vrstvu
- [ ] přidat jednoduchý frontend nebo API dokumentaci