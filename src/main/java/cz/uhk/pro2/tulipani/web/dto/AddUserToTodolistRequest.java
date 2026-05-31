package cz.uhk.pro2.tulipani.web.dto;

import jakarta.validation.constraints.NotNull;

public record AddUserToTodolistRequest(@NotNull Long userId, Long roleId) {
}

