package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.web.dto.AuthLoginRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthRegisterRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataAccessException;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final AppRoleRepository appRoleRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public AuthResponse register(AuthRegisterRequest request) {
        if (request == null) throw new IllegalArgumentException("Missing request");
        try {
            appUserRepository.findByEmail(request.email()).ifPresent(u -> {
                throw new IllegalArgumentException("Email already registered");
            });

            var authId = java.util.UUID.randomUUID();
            var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder()
                .email(request.email())
                .name(request.name())
                .surname(request.surname())
                .authId(authId)
                .build();

            user = appUserRepository.save(user);

            return new AuthResponse(authId.toString(), user.getUserId(), user.getEmail(), null);
        } catch (DataAccessException dae) {
            throw new IllegalStateException("Database error during registration: " + dae.getMessage(), dae);
        }
    }

    public AuthResponse login(AuthLoginRequest request) {
        if (request == null) throw new IllegalArgumentException("Missing request");
        var user = appUserRepository.findByEmail(request.email())
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // NOTE: password is not validated - external auth expected. Return authId as token.
        return new AuthResponse(user.getAuthId() != null ? user.getAuthId().toString() : null, user.getUserId(), user.getEmail(), null);
    }
}