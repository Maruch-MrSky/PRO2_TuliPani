package cz.uhk.pro2.tulipani.web.dto;

import java.time.LocalDateTime;

import jakarta.validation.constraints.NotBlank;

public record CreateTaskRequest(
        @NotBlank String name,
        String description,
        LocalDateTime deadline,
        Integer todolistId,
        Integer categoryId) {
}