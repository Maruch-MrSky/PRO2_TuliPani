package cz.uhk.pro2.tulipani.service.port;

import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import java.util.List;

public interface TodolistOperations {
	List<TodolistResponse> listTodolists(String authId);

	TodolistResponse createTodolist(CreateTodolistRequest request, String authId);

	TodolistResponse getTodolist(Long id, String authId);

	void deleteTodolist(Long id, String authId);
}
