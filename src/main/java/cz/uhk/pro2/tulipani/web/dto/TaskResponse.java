package cz.uhk.pro2.tulipani.web.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record TaskResponse(
        Integer taskId,
        String name,
        String description,
        LocalDateTime deadline,
        String state,
        Integer todolistId,
        Integer categoryId,
        Integer taskCreator,
        String updatedBy) {
}