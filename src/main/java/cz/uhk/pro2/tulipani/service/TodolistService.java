package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.GroupRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistUserRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TodolistService {

    private final TodolistRepository todolistRepository;
    private final TodolistUserRepository todolistUserRepository;
    private final AppUserRepository appUserRepository;
    private final GroupRoleRepository groupRoleRepository;

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
        throw new UnsupportedOperationException("TODO: add user to todolist");
    }

    public void removeUserFromTodolist(Long todolistId, Long userId) {
        throw new UnsupportedOperationException("TODO: remove user from todolist");
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
        throw new UnsupportedOperationException("TODO: get todolist");
    }

    public void deleteTodolist(Long id, String authId) {
        throw new UnsupportedOperationException("TODO: delete todolist");
    }
}