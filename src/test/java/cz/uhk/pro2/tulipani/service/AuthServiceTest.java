package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.web.dto.AuthLoginRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthRegisterRequest;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AppUserRepository appUserRepository;

    @Mock
    private AppRoleRepository appRoleRepository;

    @InjectMocks
    private AuthService authService;

    @Test
    void register_updatesExistingUserAndGeneratesAuthIdWhenMissing() {
        var existing = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder()
            .userId(10)
            .email("user@example.com")
            .name("Old")
            .surname("Name")
            .authId(null)
            .build();
        when(appUserRepository.findByEmail("user@example.com")).thenReturn(Optional.of(existing));
        when(appUserRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        var response = authService.register(new AuthRegisterRequest("user@example.com", "secret", "New", "User"));

        assertThat(response.email()).isEqualTo("user@example.com");
        assertThat(response.token()).isNotBlank();
        assertThat(existing.getName()).isEqualTo("New");
        assertThat(existing.getSurname()).isEqualTo("User");
        assertThat(existing.getAuthId()).isNotNull();
        verify(appUserRepository).save(existing);
    }

    @Test
    void login_generatesAuthIdForExistingUserWithoutOne() {
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder()
            .userId(11)
            .email("fresh@example.com")
            .authId(null)
            .build();
        when(appUserRepository.findByEmail("fresh@example.com")).thenReturn(Optional.of(user));
        when(appUserRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        var response = authService.login(new AuthLoginRequest("fresh@example.com", "secret"));

        assertThat(response.email()).isEqualTo("fresh@example.com");
        assertThat(response.token()).isNotBlank();
        assertThat(user.getAuthId()).isNotNull();
        verify(appUserRepository).save(user);
    }
}
