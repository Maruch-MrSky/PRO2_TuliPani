package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/todolists")
@RequiredArgsConstructor
public class TodolistController {

    private final TodolistService todolistService;

    @GetMapping
    public ResponseEntity<List<TodolistResponse>> listTodolists(@RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        List<TodolistResponse> list = todolistService.listTodolists(authId);
        return ResponseEntity.ok(list);
    }

    @PostMapping
    public ResponseEntity<TodolistResponse> createTodolist(@Valid @RequestBody CreateTodolistRequest request,
                                                            @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        TodolistResponse created = todolistService.createTodolist(request, authId);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TodolistResponse> getTodolist(@PathVariable Long id,
                                                        @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        TodolistResponse dto = todolistService.getTodolist(id, authId);
        return ResponseEntity.ok(dto);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTodolist(@PathVariable Long id,
                                               @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        todolistService.deleteTodolist(id, authId);
        return ResponseEntity.noContent().build();
    }
}