package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<Void> getCurrentUser() {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }
}