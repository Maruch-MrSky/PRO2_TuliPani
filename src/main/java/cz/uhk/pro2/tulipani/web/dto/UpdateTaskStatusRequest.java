package cz.uhk.pro2.tulipani.web.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateTaskStatusRequest(@NotBlank String state) {
}