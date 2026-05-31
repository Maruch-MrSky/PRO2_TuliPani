package cz.uhk.pro2.tulipani.util;

import java.util.UUID;

public final class AuthUtils {
    private AuthUtils() {}

    public static UUID parseAuthId(String authId) {
        if (authId == null || authId.isBlank()) {
            throw new IllegalArgumentException("Missing or empty authId header");
        }
        try {
            return UUID.fromString(authId);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid authId format", e);
        }
    }
}
