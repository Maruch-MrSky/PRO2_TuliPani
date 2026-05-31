package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.AuthService;
import cz.uhk.pro2.tulipani.web.dto.AuthLoginRequest;
import cz.uhk.pro2.tulipani.web.dto.AuthRegisterRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.validation.Valid;

@Controller
@RequestMapping("/ui/auth")
@RequiredArgsConstructor
public class UiAuthController {

    private final AuthService authService;

    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("loginRequest", new AuthLoginRequest("", ""));
        return "login";
    }

    @PostMapping("/login")
    public String login(@Valid @ModelAttribute("loginRequest") AuthLoginRequest req, BindingResult br, Model model) {
        if (br.hasErrors()) return "login";
        try {
            var resp = authService.login(req);
            if (resp.token() != null) {
                return "redirect:/ui/todolists?authId=" + resp.token();
            }
            model.addAttribute("error", "Login succeeded but no token");
            return "login";
        } catch (Exception ex) {
            model.addAttribute("error", ex.getMessage());
            return "login";
        }
    }

    @GetMapping("/register")
    public String registerForm(Model model) {
        model.addAttribute("registerRequest", new AuthRegisterRequest("", "", "", ""));
        return "register";
    }

    @PostMapping("/register")
    public String register(@Valid @ModelAttribute("registerRequest") AuthRegisterRequest req, BindingResult br, Model model) {
        if (br.hasErrors()) return "register";
        try {
            var resp = authService.register(req);
            model.addAttribute("authId", resp.token());
            model.addAttribute("userId", resp.userId());
            return "registered";
        } catch (Exception ex) {
            model.addAttribute("error", ex.getMessage());
            return "register";
        }
    }
}
