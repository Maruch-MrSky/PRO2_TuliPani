package cz.uhk.pro2.tulipani.web.dto;

import java.time.LocalDateTime;

public record TaskResponse(
        Long taskId,
        String name,
        String description,
        LocalDateTime deadline,
        String state,
        Long todolistId,
        Long categoryId,
        Long taskCreator,
        String updatedBy) {
}