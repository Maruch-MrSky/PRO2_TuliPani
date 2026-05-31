package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.domain.entity.TaskUser;
import cz.uhk.pro2.tulipani.service.TaskService;
import cz.uhk.pro2.tulipani.web.dto.AssignUserToTaskRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tasks/{taskId}/users")
@RequiredArgsConstructor
@Validated
public class TaskUsersController {

    private final TaskService taskService;

    @GetMapping
    public ResponseEntity<List<Long>> listAssignedUsers(@PathVariable Long taskId) {
        var users = taskService.listUsersForTask(taskId);
        var ids = users.stream().map(TaskUser::getUserId).collect(Collectors.toList());
        return ResponseEntity.ok(ids);
    }

    @PostMapping
    public ResponseEntity<Void> assignUser(@PathVariable Long taskId, @RequestHeader(value = "X-Auth-Id", required = false) String authId,
                                           @RequestBody AssignUserToTaskRequest req) {
        taskService.assignUserToTask(authId, taskId, req.userId());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> unassignUser(@PathVariable Long taskId, @PathVariable Long userId,
                                             @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        taskService.unassignUserFromTask(authId, taskId, userId);
        return ResponseEntity.noContent().build();
    }
}

