package cz.uhk.pro2.tulipani.service.adapter;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.service.port.TodolistOperations;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("!supabase-api")
@RequiredArgsConstructor
public class TodolistOperationsJpaAdapter implements TodolistOperations {
	private final TodolistService todolistService;

	@Override
	public List<TodolistResponse> listTodolists(String authId) {
		return todolistService.listTodolists(authId);
	}

	@Override
	public TodolistResponse createTodolist(CreateTodolistRequest request, String authId) {
		return todolistService.createTodolist(request, authId);
	}

	@Override
	public TodolistResponse getTodolist(Long id, String authId) {
		return todolistService.getTodolist(id, authId);
	}

	@Override
	public void deleteTodolist(Long id, String authId) {
		todolistService.deleteTodolist(id, authId);
	}
}
