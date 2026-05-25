package cz.uhk.pro2.tulipani.web.dto;

public record AuthResponse(
        String token,
        Long userId,
        String email,
        String roleName) {
}