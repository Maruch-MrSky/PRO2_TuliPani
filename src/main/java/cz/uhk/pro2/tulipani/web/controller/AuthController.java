package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.AuthService;
import cz.uhk.pro2.tulipani.web.dto.AuthLoginRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthRegisterRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthResponse;
import cz.uhk.pro2.tulipani.web.exception.ErrorResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody AuthRegisterRequest request) {
        try {
            AuthResponse resp = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(resp);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse(ex.getMessage(), List.of(), OffsetDateTime.now()));
        } catch (UnsupportedOperationException ex) {
            return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).body(new ErrorResponse("Not implemented", List.of(ex.getMessage()), OffsetDateTime.now()));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ErrorResponse("Internal error", List.of(ex.getMessage()), OffsetDateTime.now()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody AuthLoginRequest request) {
        try {
            AuthResponse resp = authService.login(request);
            return ResponseEntity.ok(resp);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(new ErrorResponse(ex.getMessage(), List.of(), OffsetDateTime.now()));
        } catch (UnsupportedOperationException ex) {
            return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).body(new ErrorResponse("Not implemented", List.of(ex.getMessage()), OffsetDateTime.now()));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ErrorResponse("Internal error", List.of(ex.getMessage()), OffsetDateTime.now()));
        }
    }
}