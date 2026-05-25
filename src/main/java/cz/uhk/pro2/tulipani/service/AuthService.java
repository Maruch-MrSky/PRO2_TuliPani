package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.web.dto.AuthLoginRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthRegisterRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final AppRoleRepository appRoleRepository;

    public AuthResponse register(AuthRegisterRequest request) {
        throw new UnsupportedOperationException("TODO: register user against Supabase schema");
    }

    public AuthResponse login(AuthLoginRequest request) {
        throw new UnsupportedOperationException("TODO: authenticate user and issue JWT");
    }
}