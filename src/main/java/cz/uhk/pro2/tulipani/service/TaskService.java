package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.domain.repository.GroupRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.util.AuthUtils;
import cz.uhk.pro2.tulipani.domain.repository.AuditLogRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import lombok.RequiredArgsConstructor;
import java.util.UUID;
import java.util.List;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import cz.uhk.pro2.tulipani.domain.repository.TodolistUserRepository;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final TaskUserRepository taskUserRepository;
    private final TodolistRepository todolistRepository;
    private final TodolistUserRepository todolistUserRepository;
    private final AppUserRepository appUserRepository;
    private final CategoryRepository categoryRepository;
    private final GroupRoleRepository groupRoleRepository;
    private final AuditLogRepository auditLogRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional
    public TaskResponse createTask(CreateTaskRequest request, String authId) {
        var user = appUserRepository.findByAuthId(AuthUtils.parseAuthId(authId))
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        setRequestJwtSub(user.getAuthId());

        var todolist = todolistRepository.findById(request.todolistId())
            .orElseThrow(() -> new IllegalArgumentException("Todolist not found"));

        if (request.categoryId() != null) {
            categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        }

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder()
            .name(request.name())
            .description(request.description())
            .deadline(request.deadline())
            .state("todo")
            .todolistId(request.todolistId())
            .categoryId(request.categoryId())
                .taskCreator(user.getUserId())
                .updatedBy(user.getAuthId() != null ? user.getAuthId().toString() : null)
            .build();

        task = taskRepository.save(task);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("create_task")
            .logTime(java.time.LocalDateTime.now())
            .userId(user.getUserId())
            .taskId(task.getTaskId())
            .build();

        auditLogRepository.save(audit);

        return new TaskResponse(task.getTaskId(), task.getName(), task.getDescription(), task.getDeadline(), task.getState(), task.getTodolistId(), task.getCategoryId(), task.getTaskCreator(), task.getUpdatedBy());
    }

    @Transactional(readOnly = true)
    public List<TaskResponse> listTasksForTodolist(Integer todolistId, String authId, Integer categoryId, String state, String search) {
        var user = appUserRepository.findByAuthId(AuthUtils.parseAuthId(authId))
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var membership = todolistUserRepository.findByTodolistIdAndUserId(todolistId, user.getUserId())
            .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

        var allowed = Boolean.TRUE.equals(membership.getIsListCreator())
            || membership.getRole() != null;
        if (!allowed) {
            throw new IllegalStateException("Actor lacks permission to view todolist tasks");
        }

        return taskRepository.findByTodolistId(todolistId).stream()
            .filter(task -> categoryId == null || categoryId.equals(task.getCategoryId()))
            .filter(task -> state == null || state.isBlank() || state.equalsIgnoreCase(task.getState()))
            .filter(task -> search == null || search.isBlank()
                || containsIgnoreCase(task.getName(), search)
                || containsIgnoreCase(task.getDescription(), search))
            .map(task -> new TaskResponse(task.getTaskId(), task.getName(), task.getDescription(), task.getDeadline(), task.getState(), task.getTodolistId(), task.getCategoryId(), task.getTaskCreator(), task.getUpdatedBy()))
            .toList();
    }

        public TaskResponse getTask(Integer taskId, String authId) {
        var user = appUserRepository.findByAuthId(AuthUtils.parseAuthId(authId))
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var task = taskRepository.findById(taskId)
            .orElseThrow(() -> new IllegalArgumentException("Task not found"));

        return new TaskResponse(task.getTaskId(), task.getName(), task.getDescription(), task.getDeadline(), task.getState(), task.getTodolistId(), task.getCategoryId(), task.getTaskCreator(), task.getUpdatedBy());
        }

    private static boolean containsIgnoreCase(String value, String search) {
        if (value == null || search == null) {
            return false;
        }
        return value.toLowerCase().contains(search.toLowerCase());
    }

    @Transactional
    public void assignUserToTask(String actorAuthId, Integer taskId, Integer userId) {
        assignUserToTaskInternal(actorAuthId, taskId, userId);
    }

    @Transactional
    public void unassignUserFromTask(String actorAuthId, Integer taskId, Integer userId) {
        unassignUserFromTaskInternal(actorAuthId, taskId, userId);
    }

            @Transactional
            void assignUserToTaskInternal(String actorAuthId, Integer taskId, Integer userId) {
            var task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found"));

            var actor = appUserRepository.findByAuthId(AuthUtils.parseAuthId(actorAuthId))
                .orElseThrow(() -> new IllegalArgumentException("Actor not found"));

            setRequestJwtSub(actor.getAuthId());

            var todolistId = task.getTodolistId();

            var membership = todolistUserRepository.findByTodolistIdAndUserId(todolistId, actor.getUserId())
                .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

            var allowed = Boolean.TRUE.equals(membership.getIsListCreator())
                || (membership.getRole() != null && "spravce".equalsIgnoreCase(membership.getRole().getRoleName()));

            if (!allowed) {
                throw new IllegalStateException("Actor lacks permission to assign users");
            }

            var user = appUserRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

            if (taskUserRepository.existsByTaskIdAndUserId(taskId, userId)) {
                throw new IllegalStateException("User already assigned to task");
            }

            var tu = cz.uhk.pro2.tulipani.domain.entity.TaskUser.builder()
                .taskId(taskId)
                .userId(userId)
                .build();

            taskUserRepository.save(tu);

            var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
                .action("assign_user_to_task")
                .logTime(java.time.LocalDateTime.now())
                .userId(actor.getUserId())
                .taskId(taskId)
                .build();

            auditLogRepository.save(audit);
            }

            @Transactional
            void unassignUserFromTaskInternal(String actorAuthId, Integer taskId, Integer userId) {
            var task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found"));

            var actor = appUserRepository.findByAuthId(AuthUtils.parseAuthId(actorAuthId))
                .orElseThrow(() -> new IllegalArgumentException("Actor not found"));

            setRequestJwtSub(actor.getAuthId());

            var todolistId = task.getTodolistId();

            var membership = todolistUserRepository.findByTodolistIdAndUserId(todolistId, actor.getUserId())
                .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

            var allowed = Boolean.TRUE.equals(membership.getIsListCreator())
                || (membership.getRole() != null && "spravce".equalsIgnoreCase(membership.getRole().getRoleName()))
                || actor.getUserId().equals(userId);

            if (!allowed) {
                throw new IllegalStateException("Actor lacks permission to unassign users");
            }

            var tu = taskUserRepository.findByTaskIdAndUserId(taskId, userId)
                .orElseThrow(() -> new IllegalArgumentException("TaskUser not found"));

            taskUserRepository.delete(tu);

            var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
                .action("unassign_user_from_task")
                .logTime(java.time.LocalDateTime.now())
                .userId(actor.getUserId())
                .taskId(taskId)
                .build();

            auditLogRepository.save(audit);
            }

    @Transactional
    public TaskResponse updateTaskStatus(Integer taskId, UpdateTaskStatusRequest request, String authId) {
        var actor = appUserRepository.findByAuthId(AuthUtils.parseAuthId(authId))
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        setRequestJwtSub(actor.getAuthId());

        var task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found"));

        var allowed = false;

        if (task.getTaskCreator() != null && task.getTaskCreator().equals(actor.getUserId())) {
            allowed = true;
        }

        if (!allowed && taskUserRepository.existsByTaskIdAndUserId(taskId, actor.getUserId())) {
            allowed = true;
        }

        if (!allowed) {
            var membership = todolistUserRepository.findByTodolistIdAndUserId(task.getTodolistId(), actor.getUserId());
            if (membership.isPresent()) {
                var m = membership.get();
                allowed = Boolean.TRUE.equals(m.getIsListCreator()) || (m.getRole() != null && "spravce".equalsIgnoreCase(m.getRole().getRoleName()));
            }
        }

        if (!allowed) {
            throw new IllegalStateException("Actor lacks permission to update task status");
        }

        ensureWritableTaskRole(actor.getUserId(), task.getTodolistId());

        var status = request.state();
        if (status == null || !(status.equals("todo") || status.equals("in_progress") || status.equals("done"))) {
            throw new IllegalArgumentException("Invalid status");
        }

        task.setState(status);
        task.setUpdatedBy(actor.getAuthId() != null ? actor.getAuthId().toString() : null);

        task = taskRepository.save(task);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("update_task_status")
            .logTime(java.time.LocalDateTime.now())
            .userId(actor.getUserId())
            .taskId(task.getTaskId())
            .build();

        auditLogRepository.save(audit);

        return new TaskResponse(task.getTaskId(), task.getName(), task.getDescription(), task.getDeadline(), task.getState(), task.getTodolistId(), task.getCategoryId(), task.getTaskCreator(), task.getUpdatedBy());
    }

    @Transactional
    public void deleteTask(Integer taskId, String authId) {
            var actor = appUserRepository.findByAuthId(AuthUtils.parseAuthId(authId))
                .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        setRequestJwtSub(actor.getAuthId());

        var task = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found"));

        var allowed = false;
        if (task.getTaskCreator() != null && task.getTaskCreator().equals(actor.getUserId())) {
            allowed = true;
        }

        if (!allowed && taskUserRepository.existsByTaskIdAndUserId(taskId, actor.getUserId())) {
            allowed = true;
        }

        if (!allowed) {
            var membership = todolistUserRepository.findByTodolistIdAndUserId(task.getTodolistId(), actor.getUserId());
            if (membership.isPresent()) {
                var m = membership.get();
                allowed = Boolean.TRUE.equals(m.getIsListCreator()) || (m.getRole() != null && "spravce".equalsIgnoreCase(m.getRole().getRoleName()));
            }
        }

        if (!allowed) {
            throw new IllegalStateException("Actor lacks permission to delete task");
        }

        ensureWritableTaskRole(actor.getUserId(), task.getTodolistId());

        // remove task users
        var users = taskUserRepository.findByTaskId(taskId);
        if (users != null && !users.isEmpty()) {
            taskUserRepository.deleteAll(users);
        }

        taskRepository.delete(task);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("delete_task")
            .logTime(java.time.LocalDateTime.now())
            .userId(actor.getUserId())
            .taskId(task.getTaskId())
            .build();

        auditLogRepository.save(audit);
    }

    // new helper to list task users
    public java.util.List<cz.uhk.pro2.tulipani.domain.entity.TaskUser> listUsersForTask(int taskId) {
        return taskUserRepository.findByTaskId(taskId);
    }

    private void setRequestJwtSub(UUID authId) {
        if (authId == null || entityManager == null) {
            return;
        }
        entityManager.createNativeQuery("select set_config('request.jwt.claim.sub', :sub, true)")
            .setParameter("sub", authId.toString())
            .getSingleResult();
    }

    private void ensureWritableTaskRole(Integer userId, Integer todolistId) {
        var membership = todolistUserRepository.findByTodolistIdAndUserId(todolistId, userId)
            .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

        var role = membership.getRole();
        var writableRole = role != null
            && role.getRoleName() != null
            && ("spravce".equalsIgnoreCase(role.getRoleName()) || "koordinator".equalsIgnoreCase(role.getRoleName()));

        if (writableRole) {
            return;
        }

        var spravceRole = groupRoleRepository.findAll().stream()
            .filter(r -> r.getRoleName() != null && "spravce".equalsIgnoreCase(r.getRoleName()))
            .findFirst()
            .orElseGet(() -> groupRoleRepository.save(
                cz.uhk.pro2.tulipani.domain.entity.GroupRole.builder()
                    .roleName("spravce")
                    .build()));

        membership.setRoleId(spravceRole.getRoleId());
        todolistUserRepository.save(membership);
    }
}