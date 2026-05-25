package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final TaskUserRepository taskUserRepository;
    private final TodolistRepository todolistRepository;
    private final AppUserRepository appUserRepository;
    private final CategoryRepository categoryRepository;

    public TaskResponse createTask(CreateTaskRequest request, String authId) {
        throw new UnsupportedOperationException("TODO: create task and persist audit data");
    }

    public void assignUserToTask(Long taskId, Long userId) {
        throw new UnsupportedOperationException("TODO: assign user to task");
    }

    public void unassignUserFromTask(Long taskId, Long userId) {
        throw new UnsupportedOperationException("TODO: unassign user from task");
    }

    public TaskResponse updateTaskStatus(Long taskId, UpdateTaskStatusRequest request, String authId) {
        throw new UnsupportedOperationException("TODO: update task status");
    }

    public void deleteTask(Long taskId, String authId) {
        throw new UnsupportedOperationException("TODO: delete task with permission checks");
    }
}