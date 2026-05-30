package cz.uhk.pro2.tulipani.service.adapter;

import cz.uhk.pro2.tulipani.service.TaskService;
import cz.uhk.pro2.tulipani.service.port.TaskOperations;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("!supabase-api")
@RequiredArgsConstructor
public class TaskOperationsJpaAdapter implements TaskOperations {
	private final TaskService taskService;

	@Override
	public TaskResponse createTask(CreateTaskRequest request, String authId) {
		return taskService.createTask(request, authId);
	}

	@Override
	public TaskResponse updateTaskStatus(Long taskId, UpdateTaskStatusRequest request, String authId) {
		return taskService.updateTaskStatus(taskId, request, authId);
	}

	@Override
	public void deleteTask(Long taskId, String authId) {
		taskService.deleteTask(taskId, authId);
	}
}
