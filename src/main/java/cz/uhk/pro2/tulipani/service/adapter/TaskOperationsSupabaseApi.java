package cz.uhk.pro2.tulipani.service.adapter;

import cz.uhk.pro2.tulipani.service.port.TaskOperations;
import cz.uhk.pro2.tulipani.supabase.SupabaseRest;
import cz.uhk.pro2.tulipani.supabase.dto.SupabaseRows;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.TaskResponse;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Map;
import java.util.LinkedHashMap;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("supabase-api")
@RequiredArgsConstructor
public class TaskOperationsSupabaseApi implements TaskOperations {
	private final SupabaseRest supabase;

	@Override
	public TaskResponse createTask(CreateTaskRequest request, String authId) {
		var actor = requireActor(authId);

		var list = supabase.getObject(
				"/todolist?todolist_id=eq." + request.todolistId() + "&select=todolist_id",
				SupabaseRows.TodolistRow.class);
		if (list == null) {
			throw new IllegalArgumentException("Todolist not found");
		}

		if (request.categoryId() != null) {
			var cat = supabase.getObject(
					"/category?category_id=eq." + request.categoryId() + "&select=category_id",
					SupabaseRows.CategoryRow.class);
			if (cat == null) {
				throw new IllegalArgumentException("Category not found");
			}
		}

		var payload = new LinkedHashMap<String, Object>();
		payload.put("name", request.name());
		payload.put("description", request.description());
		payload.put("deadline", request.deadline());
		payload.put("state", "todo");
		payload.put("todolist_id", request.todolistId());
		payload.put("category_id", request.categoryId());
		payload.put("task_creator", actor.userId());
		payload.put("updated_by", actor.authId());

		var task = supabase.insertReturning("task", payload, SupabaseRows.TaskRow.class);
		if (task == null || task.taskId() == null) {
			throw new IllegalStateException("Failed to create task");
		}

		insertAudit("create_task", actor.userId(), task.taskId());
		return toResponse(task);
	}

	@Override
	public TaskResponse updateTaskStatus(Long taskId, UpdateTaskStatusRequest request, String authId) {
		var actor = requireActor(authId);
		var task = requireTask(taskId);

		if (!isAllowedOnTask(actor, task)) {
			throw new IllegalStateException("Actor lacks permission to update task status");
		}

		var status = request.state();
		if (status == null || !(status.equals("todo") || status.equals("in_progress") || status.equals("done"))) {
			throw new IllegalArgumentException("Invalid status");
		}

		var updated = supabase.patchReturning(
				"task",
				"task_id=eq." + taskId,
				Map.of("state", status, "updated_by", actor.authId()),
				SupabaseRows.TaskRow.class);

		if (updated == null) {
			throw new IllegalStateException("Failed to update task status");
		}

		insertAudit("update_task_status", actor.userId(), taskId);
		return toResponse(updated);
	}

	@Override
	public void deleteTask(Long taskId, String authId) {
		var actor = requireActor(authId);
		var task = requireTask(taskId);

		if (!isAllowedOnTask(actor, task)) {
			throw new IllegalStateException("Actor lacks permission to delete task");
		}

		supabase.delete("task", "task_id=eq." + taskId);
		insertAudit("delete_task", actor.userId(), taskId);
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

	private SupabaseRows.TaskRow requireTask(Long taskId) {
		var task = supabase.getObject(
				"/task?task_id=eq." + taskId + "&select=task_id,name,description,deadline,state,todolist_id,category_id,task_creator,updated_by",
				SupabaseRows.TaskRow.class);
		if (task == null) {
			throw new IllegalArgumentException("Task not found");
		}
		return task;
	}

	private boolean isAllowedOnTask(SupabaseRows.AppUserRow actor, SupabaseRows.TaskRow task) {
		if (task.taskCreator() != null && task.taskCreator().equals(actor.userId())) {
			return true;
		}

		var tu = supabase.getObject(
				"/task_users?task_id=eq." + task.taskId() + "&user_id=eq." + actor.userId() + "&select=task_users_id",
				SupabaseRows.TaskUserRow.class);
		if (tu != null && tu.taskUsersId() != null) {
			return true;
		}

		var membership = supabase.getObject(
				"/todolist_users?todolist_id=eq." + task.todolistId() + "&user_id=eq." + actor.userId() + "&select=todolist_users_id,role_id,is_list_creator,todolist_id,user_id",
				SupabaseRows.TodolistUserRow.class);
		if (membership == null) {
			return false;
		}

		if (Boolean.TRUE.equals(membership.isListCreator())) {
			return true;
		}

		if (membership.roleId() == null) {
			return false;
		}

		var role = supabase.getObject(
				"/group_role?role_id=eq." + membership.roleId() + "&select=role_name,role_id",
				SupabaseRows.GroupRoleRow.class);
		return role != null
				&& role.roleName() != null
				&& role.roleName().toLowerCase(Locale.ROOT).equals("spravce");
	}

	private void insertAudit(String action, Long userId, Long taskId) {
		var payload = new LinkedHashMap<String, Object>();
		payload.put("action", action);
		payload.put("log_time", LocalDateTime.now());
		payload.put("user_id", userId);
		payload.put("task_id", taskId);
		supabase.insertReturning("audit_log", payload, Object.class);
	}

	private static TaskResponse toResponse(SupabaseRows.TaskRow task) {
		return new TaskResponse(
				task.taskId(),
				task.name(),
				task.description(),
				task.deadline(),
				task.state(),
				task.todolistId(),
				task.categoryId(),
				task.taskCreator(),
				task.updatedBy()
		);
	}
}
