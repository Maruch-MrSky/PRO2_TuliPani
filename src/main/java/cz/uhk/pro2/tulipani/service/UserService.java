package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.web.dto.CurrentUserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.context.annotation.Profile;

@Service
@Profile("!supabase-api")
@RequiredArgsConstructor
public class UserService {

    private final AppUserRepository appUserRepository;

    public CurrentUserResponse getCurrentUser(String authId) {
        throw new UnsupportedOperationException("TODO: resolve current user by auth_id");
    }
}