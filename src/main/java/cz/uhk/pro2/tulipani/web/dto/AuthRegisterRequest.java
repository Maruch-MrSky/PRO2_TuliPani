package cz.uhk.pro2.tulipani.web.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record AuthRegisterRequest(
        @Email @NotBlank String email,
        @NotBlank String password,
        @NotBlank String name,
        @NotBlank String surname) {
}