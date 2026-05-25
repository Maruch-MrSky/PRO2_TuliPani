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
        throw new UnsupportedOperationException("TODO: create todolist");
    }

    public void addUserToTodolist(Long todolistId, Long userId, Long roleId) {
        throw new UnsupportedOperationException("TODO: add user to todolist");
    }

    public void removeUserFromTodolist(Long todolistId, Long userId) {
        throw new UnsupportedOperationException("TODO: remove user from todolist");
    }

    public java.util.List<TodolistResponse> listTodolists(String authId) {
        throw new UnsupportedOperationException("TODO: list todolists");
    }

    public TodolistResponse getTodolist(Long id, String authId) {
        throw new UnsupportedOperationException("TODO: get todolist");
    }

    public void deleteTodolist(Long id, String authId) {
        throw new UnsupportedOperationException("TODO: delete todolist");
    }
}