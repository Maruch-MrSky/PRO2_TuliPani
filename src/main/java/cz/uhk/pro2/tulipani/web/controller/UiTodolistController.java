package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/ui/todolists")
@RequiredArgsConstructor
@Validated
public class UiTodolistController {

    private final TodolistService todolistService;

    @GetMapping
    public String list(@RequestParam(value = "authId", required = false) String authId, Model model) {
        List<TodolistResponse> lists = todolistService.listTodolists(authId);
        model.addAttribute("lists", lists);
        model.addAttribute("createRequest", new CreateTodolistRequest("", ""));
        model.addAttribute("authId", authId);
        return "todolists";
    }

    @PostMapping
    public String create(@ModelAttribute CreateTodolistRequest createRequest,
                         @RequestParam(value = "authId", required = false) String authId) {
        todolistService.createTodolist(createRequest, authId);
        return "redirect:/ui/todolists" + (authId != null ? "?authId=" + authId : "");
    }

    @GetMapping("/{id}")
    public String detail(@RequestParam(value = "authId", required = false) String authId,
                         @org.springframework.web.bind.annotation.PathVariable Integer id,
                         Model model) {
        var dto = todolistService.getTodolist(id, authId);
        model.addAttribute("todolist", dto);
        model.addAttribute("authId", authId);
        return "todolist";
    }
}
