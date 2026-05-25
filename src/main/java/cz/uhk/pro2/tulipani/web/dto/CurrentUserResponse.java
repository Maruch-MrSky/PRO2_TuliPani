package cz.uhk.pro2.tulipani.web.dto;

public record CurrentUserResponse(
        Long userId,
        String email,
        String name,
        String surname,
        String authId,
        String roleName) {
}