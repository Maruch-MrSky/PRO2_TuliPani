package cz.uhk.pro2.tulipani.service.port;

import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;

public interface TaskOperations {
	TaskResponse createTask(CreateTaskRequest request, String authId);

	TaskResponse updateTaskStatus(Long taskId, UpdateTaskStatusRequest request, String authId);

	void deleteTask(Long taskId, String authId);
}
