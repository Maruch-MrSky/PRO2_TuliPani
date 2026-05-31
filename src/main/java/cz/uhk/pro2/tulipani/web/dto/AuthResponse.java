package cz.uhk.pro2.tulipani.web.dto;

public record AuthResponse(
        String token,
        Integer userId,
        String email,
        String roleName) {
}