package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.GroupRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistUserRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import cz.uhk.pro2.tulipani.domain.repository.AuditLogRepository;

@Service
@RequiredArgsConstructor
public class TodolistService {

    private final TodolistRepository todolistRepository;
    private final TodolistUserRepository todolistUserRepository;
    private final AppUserRepository appUserRepository;
    private final GroupRoleRepository groupRoleRepository;
    private final AuditLogRepository auditLogRepository;

    public TodolistResponse createTodolist(CreateTodolistRequest request, String authId) {
        var user = appUserRepository.findByAuthId(authId)
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var todolist = cz.uhk.pro2.tulipani.domain.entity.Todolist.builder()
            .name(request.name())
            .listType(request.listType())
            .build();

        todolist = todolistRepository.save(todolist);

        // find 'spravce' group role if exists, fallback to first role
        var role = groupRoleRepository.findAll().stream()
            .filter(r -> r.getRoleName() != null && r.getRoleName().equalsIgnoreCase("spravce"))
            .findFirst()
            .orElseGet(() -> groupRoleRepository.findAll().stream().findFirst().orElse(null));

        var todolistUser = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder()
            .todolistId(todolist.getTodolistId())
            .userId(user.getUserId())
            .roleId(role != null ? role.getRoleId() : null)
            .isListCreator(Boolean.TRUE)
            .build();

        todolistUserRepository.save(todolistUser);

        return new TodolistResponse(todolist.getTodolistId(), todolist.getName(), todolist.getListType());
    }

    public void addUserToTodolist(Long todolistId, Long userId, Long roleId) {
        var list = todolistRepository.findById(todolistId)
            .orElseThrow(() -> new IllegalArgumentException("Todolist not found"));

        var user = appUserRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (todolistUserRepository.existsByTodolistIdAndUserId(todolistId, userId)) {
            throw new IllegalStateException("User already member of todolist");
        }

        var tu = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder()
            .todolistId(todolistId)
            .userId(userId)
            .roleId(roleId)
            .isListCreator(Boolean.FALSE)
            .build();

        todolistUserRepository.save(tu);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("add_user_to_todolist")
            .logTime(java.time.LocalDateTime.now())
            .userId(userId)
            .taskId(null)
            .build();

        auditLogRepository.save(audit);
    }

    public void removeUserFromTodolist(Long todolistId, Long userId) {
        var tu = todolistUserRepository.findByTodolistIdAndUserId(todolistId, userId)
            .orElseThrow(() -> new IllegalArgumentException("Todolist membership not found"));

        todolistUserRepository.delete(tu);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("remove_user_from_todolist")
            .logTime(java.time.LocalDateTime.now())
            .userId(userId)
            .taskId(null)
            .build();

        auditLogRepository.save(audit);
    }

    public java.util.List<TodolistResponse> listTodolists(String authId) {
        var user = appUserRepository.findByAuthId(authId)
                .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var memberships = todolistUserRepository.findByUserId(user.getUserId());

        return memberships.stream()
                .map(ut -> {
                    var t = ut.getTodolist();
                    if (t == null) {
                        // fallback: load by id
                        t = todolistRepository.findById(ut.getTodolistId()).orElse(null);
                    }
                    return t == null ? null : new TodolistResponse(t.getTodolistId(), t.getName(), t.getListType());
                })
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    public TodolistResponse getTodolist(Long id, String authId) {
        var actor = appUserRepository.findByAuthId(authId)
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var membership = todolistUserRepository.findByTodolistIdAndUserId(id, actor.getUserId())
            .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

        var t = todolistRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Todolist not found"));

        return new TodolistResponse(t.getTodolistId(), t.getName(), t.getListType());
    }

    public void deleteTodolist(Long id, String authId) {
        var actor = appUserRepository.findByAuthId(authId)
            .orElseThrow(() -> new IllegalArgumentException("Authenticated user not found"));

        var membership = todolistUserRepository.findByTodolistIdAndUserId(id, actor.getUserId())
            .orElseThrow(() -> new IllegalStateException("Actor is not member of todolist"));

        var allowed = Boolean.TRUE.equals(membership.getIsListCreator())
            || (membership.getRole() != null && "spravce".equalsIgnoreCase(membership.getRole().getRoleName()));

        if (!allowed) {
            throw new IllegalStateException("Actor lacks permission to delete todolist");
        }

        todolistRepository.deleteById(id);

        var audit = cz.uhk.pro2.tulipani.domain.entity.AuditLog.builder()
            .action("delete_todolist")
            .logTime(java.time.LocalDateTime.now())
            .userId(actor.getUserId())
            .taskId(null)
            .build();

        auditLogRepository.save(audit);
    }
}