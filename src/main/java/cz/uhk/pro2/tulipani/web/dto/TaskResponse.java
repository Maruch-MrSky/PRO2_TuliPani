package cz.uhk.pro2.tulipani.web.dto;

import java.time.LocalDate;

public record TaskResponse(
        Long taskId,
        String name,
        String description,
        LocalDate deadline,
        String state,
        Long todolistId,
        Long categoryId,
        Long taskCreator,
        String updatedBy) {
}