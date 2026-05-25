package cz.uhk.pro2.tulipani.web.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;

public record CreateTaskRequest(
        @NotBlank String name,
        String description,
        LocalDate deadline,
        Long todolistId,
        Long categoryId) {
}