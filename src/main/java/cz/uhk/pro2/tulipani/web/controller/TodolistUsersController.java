package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.AddUserToTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistUserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/todolists/{todolistId}/users")
@RequiredArgsConstructor
@Validated
public class TodolistUsersController {

    private final TodolistService todolistService;

    @GetMapping
    public ResponseEntity<List<TodolistUserResponse>> listUsers(@PathVariable Long todolistId) {
        var users = todolistService.getTodolistMembers(todolistId);
        var resp = users.stream().map(u -> new TodolistUserResponse(u.getUserId(), u.getRoleId(), u.getIsListCreator())).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @PostMapping
    public ResponseEntity<Void> addUser(@PathVariable Long todolistId, @RequestBody AddUserToTodolistRequest req) {
        todolistService.addUserToTodolist(todolistId, req.userId(), req.roleId());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PutMapping("/{userId}")
    public ResponseEntity<Void> updateUserRole(@PathVariable Long todolistId, @PathVariable Long userId, @RequestBody AddUserToTodolistRequest req) {
        todolistService.changeUserRoleInTodolist(todolistId, userId, req.roleId());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> removeUser(@PathVariable Long todolistId, @PathVariable Long userId) {
        todolistService.removeUserFromTodolist(todolistId, userId);
        return ResponseEntity.noContent().build();
    }
}

