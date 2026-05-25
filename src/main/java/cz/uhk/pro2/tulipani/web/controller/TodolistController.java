package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/todolists")
@RequiredArgsConstructor
public class TodolistController {

    private final TodolistService todolistService;

    @GetMapping
    public ResponseEntity<Void> listTodolists() {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }

    @PostMapping
    public ResponseEntity<Void> createTodolist(@Valid @RequestBody CreateTodolistRequest request) {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Void> getTodolist(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTodolist(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }
}