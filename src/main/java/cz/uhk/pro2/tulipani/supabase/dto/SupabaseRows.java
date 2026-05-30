package cz.uhk.pro2.tulipani.supabase.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public final class SupabaseRows {
	private SupabaseRows() {
	}

	public record AppUserRow(
			@JsonProperty("user_id") Long userId,
			@JsonProperty("auth_id") String authId
	) {
	}

	public record TaskRow(
			@JsonProperty("task_id") Long taskId,
			@JsonProperty("name") String name,
			@JsonProperty("description") String description,
			@JsonProperty("deadline") LocalDateTime deadline,
			@JsonProperty("state") String state,
			@JsonProperty("todolist_id") Long todolistId,
			@JsonProperty("category_id") Long categoryId,
			@JsonProperty("task_creator") Long taskCreator,
			@JsonProperty("updated_by") String updatedBy
	) {
	}

	public record TodolistRow(
			@JsonProperty("todolist_id") Long todolistId,
			@JsonProperty("name") String name,
			@JsonProperty("list_type") String listType
	) {
	}

	public record CategoryRow(
			@JsonProperty("category_id") Long categoryId
	) {
	}

	public record TaskUserRow(
			@JsonProperty("task_users_id") Long taskUsersId
	) {
	}

	public record TodolistUserRow(
			@JsonProperty("todolist_users_id") Long todolistUsersId,
			@JsonProperty("todolist_id") Long todolistId,
			@JsonProperty("user_id") Long userId,
			@JsonProperty("role_id") Long roleId,
			@JsonProperty("is_list_creator") Boolean isListCreator
	) {
	}

	public record GroupRoleRow(
			@JsonProperty("role_id") Long roleId,
			@JsonProperty("role_name") String roleName
	) {
	}
}
