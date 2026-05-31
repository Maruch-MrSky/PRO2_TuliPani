package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TaskService;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;

class TaskControllerTest {

    @Mock
    private TaskService taskService;

    private TaskController taskController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        taskController = new TaskController(taskService);
    }

    @Test
    void createTask_returnsCreatedTask() {
        CreateTaskRequest request = new CreateTaskRequest("Task A", "Description", null, 1L, 2L);
        TaskResponse response = new TaskResponse(10L, "Task A", "Description", null, "todo", 1L, 2L, 100L, "100");
        when(taskService.createTask(request, "auth-1")).thenReturn(response);

        ResponseEntity<TaskResponse> result = taskController.createTask(request, "auth-1");

        assertEquals(HttpStatus.CREATED, result.getStatusCode());
        assertEquals(response, result.getBody());
    }

    @Test
    void updateTaskStatus_returnsUpdatedTask() {
        UpdateTaskStatusRequest request = new UpdateTaskStatusRequest("done");
        TaskResponse response = new TaskResponse(10L, "Task A", "Description", LocalDateTime.of(2026, 1, 10, 0, 0), "done", 1L, 2L, 100L, "101");
        when(taskService.updateTaskStatus(10L, request, "auth-1")).thenReturn(response);

        ResponseEntity<TaskResponse> result = taskController.updateTaskStatus(10L, request, "auth-1");

        assertEquals(HttpStatus.OK, result.getStatusCode());
        assertEquals(response, result.getBody());
    }

    @Test
    void deleteTask_returnsNoContent() {
        doNothing().when(taskService).deleteTask(10L, "auth-1");

        ResponseEntity<Void> result = taskController.deleteTask(10L, "auth-1");

        assertEquals(HttpStatus.NO_CONTENT, result.getStatusCode());
        assertEquals(null, result.getBody());
    }
}
