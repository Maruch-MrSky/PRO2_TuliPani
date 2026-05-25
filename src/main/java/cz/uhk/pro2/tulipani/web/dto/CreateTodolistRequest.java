package cz.uhk.pro2.tulipani.web.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateTodolistRequest(
        @NotBlank String name,
        String listType) {
}