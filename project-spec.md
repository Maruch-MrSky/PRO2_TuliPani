# Todo Application – Backend Specification

## Adress
http://localhost:8080/ui/auth/login


## Overview
This project is a multi-layer web application for managing Todo lists, tasks, and team collaboration.

The backend is implemented in:
- Java (Spring Boot)
- ORM: JPA (Hibernate)
- Architecture: Controller → Service → Repository → Database

---

## Architecture Rules

- Use Dependency Injection (IoC, DI)
- Follow layered architecture:
  - Controller = HTTP layer
  - Service = business logic
  - Repository = database access
- Do NOT put business logic in controllers
- Use DTOs (do not expose entities directly)

---

## Database Schema

Main tables:

- app_user (user_id, email, name, surname, auth_id, app_role_id)
- app_role (app_role_id, role_name)
- todolist (todolist_id, name, list_type)
- todolist_users (todolist_users_id, user_id, todolist_id, role_id, is_list_creator)
- group_role (role_id, role_name)
- task (task_id, name, description, deadline, state, todolist_id, category_id, task_creator, updated_by)
- task_users (task_users_id, user_id, task_id)
- category (category_id, name, color_hex)
- comment (comment_id, text, created_at, user_id, task_id)
- attachment (attachment_id, file_name, file_path, task_id)
- audit_log (audit_log_id, action, log_time, user_id, task_id)
- user_settings (user_settings_id, preferences, user_id)

---

## Core Concepts

- A user belongs to multiple todolists
- A todolist contains tasks
- Tasks can be assigned to multiple users
- Roles exist on:
  - global level (app_role)
  - todolist level (group_role via todolist_users)

---

## Task States

Allowed values:
- todo
- in_progress
- done

---

## API Specification

### Auth

POST `/api/auth/register`
POST `/api/auth/login`

---

### User

GET `/api/users/me`

---

### Todolist

GET `/api/todolists`  
POST `/api/todolists`  
GET `/api/todolists/{id}`  
DELETE `/api/todolists/{id}`  

---

### Todolist Users

GET `/api/todolists/{id}/users`  
POST `/api/todolists/{id}/users`  
PUT `/api/todolists/{id}/users/{userId}`  
DELETE `/api/todolists/{id}/users/{userId}`  

---

### Task

POST `/api/tasks`  
GET `/api/tasks/{id}`  
PUT `/api/tasks/{id}`  
PATCH `/api/tasks/{id}/status`  
DELETE `/api/tasks/{id}`  

---

### Task Users

GET `/api/tasks/{id}/users`  
POST `/api/tasks/{id}/users`  
DELETE `/api/tasks/{id}/users/{userId}`  

---

### Comments

POST `/api/tasks/{id}/comments`

---

### Attachments

POST `/api/tasks/{id}/attachments`

---

## Service Layer Responsibilities

Implement business logic for:

- createTodolist
- addUserToTodolist
- removeUserFromTodolist
- createTask
- assignUserToTask
- unassignUserFromTask
- updateTaskStatus
- deleteTask

Include validation:
- prevent duplicates
- check existence
- enforce role permissions

---

## Security

- Use Spring Security
- JWT authentication
- Allow `/api/auth/**` without auth
- Secure all other endpoints
- Map authenticated user via `auth_id`

---

## Coding Conventions

- Use constructor injection
- Use meaningful method names
- Keep controllers thin
- Use DTOs for API
- Follow REST naming conventions

---

## Testing

Use JUnit + Mockito

Test:
- createTask
- addUserToTodolist
- assignUserToTask
- updateTaskStatus
- deleteTask

---

## Goal

Produce clean, maintainable, production-like backend code that:
- follows Spring Boot best practices
- respects database structure
- supports team collaboration features