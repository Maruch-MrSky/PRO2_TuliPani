package cz.uhk.pro2.tulipani.service.adapter;

import com.fasterxml.jackson.core.type.TypeReference;
import cz.uhk.pro2.tulipani.service.port.TodolistOperations;
import cz.uhk.pro2.tulipani.supabase.SupabaseRest;
import cz.uhk.pro2.tulipani.supabase.dto.SupabaseRows;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("supabase-api")
@RequiredArgsConstructor
public class TodolistOperationsSupabaseApi implements TodolistOperations {
	private static final TypeReference<List<SupabaseRows.TodolistUserRow>> TODOLIST_USERS_LIST =
			new TypeReference<>() {
			};
	private static final TypeReference<List<SupabaseRows.TodolistRow>> TODOLIST_LIST =
			new TypeReference<>() {
			};
	private final SupabaseRest supabase;

	@Override
	public List<TodolistResponse> listTodolists(String authId) {
		var actor = requireActor(authId);

		var memberships = supabase.getList(
				"/todolist_users?user_id=eq." + actor.userId() + "&select=todolist_id,todolist_users_id,user_id,role_id,is_list_creator",
				TODOLIST_USERS_LIST);
		var ids = memberships.stream()
				.map(SupabaseRows.TodolistUserRow::todolistId)
				.filter(id -> id != null)
				.distinct()
				.toList();

		if (ids.isEmpty()) {
			return List.of();
		}

		var inClause = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
		var lists = supabase.getList(
				"/todolist?select=todolist_id,name,list_type&todolist_id=in.(" + inClause + ")",
				TODOLIST_LIST);

		return lists.stream()
				.map(t -> new TodolistResponse(t.todolistId(), t.name(), t.listType()))
				.toList();
	}

	@Override
	public TodolistResponse createTodolist(CreateTodolistRequest request, String authId) {
		var actor = requireActor(authId);

		var listPayload = new LinkedHashMap<String, Object>();
		listPayload.put("name", request.name());
		listPayload.put("list_type", request.listType());
		var list = supabase.insertReturning("todolist", listPayload, SupabaseRows.TodolistRow.class);
		if (list == null || list.todolistId() == null) {
			throw new IllegalStateException("Failed to create todolist");
		}

		var role = supabase.getObject(
				"/group_role?role_name=ilike.spravce&select=role_id,role_name&limit=1",
				SupabaseRows.GroupRoleRow.class);
		if (role == null) {
			role = supabase.getObject(
					"/group_role?select=role_id,role_name&limit=1",
					SupabaseRows.GroupRoleRow.class);
		}

		var membershipPayload = new LinkedHashMap<String, Object>();
		membershipPayload.put("todolist_id", list.todolistId());
		membershipPayload.put("user_id", actor.userId());
		membershipPayload.put("role_id", role != null ? role.roleId() : null);
		membershipPayload.put("is_list_creator", true);
		supabase.insertReturning("todolist_users", membershipPayload, Object.class);

		return new TodolistResponse(list.todolistId(), list.name(), list.listType());
	}

	@Override
	public TodolistResponse getTodolist(Long id, String authId) {
		var actor = requireActor(authId);

		var membership = supabase.getObject(
				"/todolist_users?todolist_id=eq." + id + "&user_id=eq." + actor.userId() + "&select=todolist_users_id",
				SupabaseRows.TodolistUserRow.class);
		if (membership == null) {
			throw new IllegalStateException("Actor is not member of todolist");
		}

		var list = supabase.getObject(
				"/todolist?todolist_id=eq." + id + "&select=todolist_id,name,list_type",
				SupabaseRows.TodolistRow.class);
		if (list == null) {
			throw new IllegalArgumentException("Todolist not found");
		}

		return new TodolistResponse(list.todolistId(), list.name(), list.listType());
	}

	@Override
	public void deleteTodolist(Long id, String authId) {
		var actor = requireActor(authId);

		var membership = supabase.getObject(
				"/todolist_users?todolist_id=eq." + id + "&user_id=eq." + actor.userId()
						+ "&select=todolist_users_id,role_id,is_list_creator,todolist_id,user_id",
				SupabaseRows.TodolistUserRow.class);
		if (membership == null) {
			throw new IllegalStateException("Actor is not member of todolist");
		}

		var allowed = Boolean.TRUE.equals(membership.isListCreator());
		if (!allowed && membership.roleId() != null) {
			var role = supabase.getObject(
					"/group_role?role_id=eq." + membership.roleId() + "&select=role_name,role_id",
					SupabaseRows.GroupRoleRow.class);
			allowed = role != null
					&& role.roleName() != null
					&& role.roleName().toLowerCase(Locale.ROOT).equals("spravce");
		}

		if (!allowed) {
			throw new IllegalStateException("Actor lacks permission to delete todolist");
		}

		supabase.delete("todolist", "todolist_id=eq." + id);
		insertAudit("delete_todolist", actor.userId());
	}

	private SupabaseRows.AppUserRow requireActor(String authId) {
		if (authId == null || authId.isBlank()) {
			throw new IllegalArgumentException("Authenticated user not found");
		}
		var actor = supabase.getObject(
				"/app_user?auth_id=eq." + SupabaseRest.enc(authId) + "&select=user_id,auth_id",
				SupabaseRows.AppUserRow.class);
		if (actor == null || actor.userId() == null) {
			throw new IllegalArgumentException("Authenticated user not found");
		}
		return actor;
	}

	private void insertAudit(String action, Long userId) {
		var payload = new LinkedHashMap<String, Object>();
		payload.put("action", action);
		payload.put("log_time", LocalDateTime.now());
		payload.put("user_id", userId);
		payload.put("task_id", null);
		supabase.insertReturning("audit_log", payload, Object.class);
	}
}
