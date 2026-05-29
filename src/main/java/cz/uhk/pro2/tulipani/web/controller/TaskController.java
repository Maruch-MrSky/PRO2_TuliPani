package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TaskService;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @PostMapping
    public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody CreateTaskRequest request,
                                                   @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        TaskResponse created = taskService.createTask(request, authId);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskResponse> updateTaskStatus(@PathVariable Long id,
                                                         @Valid @RequestBody UpdateTaskStatusRequest request,
                                                         @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        TaskResponse updated = taskService.updateTaskStatus(id, request, authId);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id,
                                           @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        taskService.deleteTask(id, authId);
        return ResponseEntity.noContent().build();
    }
}