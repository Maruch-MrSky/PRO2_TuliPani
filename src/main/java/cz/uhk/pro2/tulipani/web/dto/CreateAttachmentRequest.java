package cz.uhk.pro2.tulipani.web.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateAttachmentRequest(@NotBlank String filename, @NotBlank String filePath) {
}

