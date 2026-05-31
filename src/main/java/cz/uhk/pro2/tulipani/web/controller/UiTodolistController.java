package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.domain.entity.Category;
import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.service.TaskService;
import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest;
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
import java.util.Map;
import java.util.stream.Collectors;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Controller
@RequestMapping("/ui/todolists")
@RequiredArgsConstructor
@Validated
public class UiTodolistController {

    private final TodolistService todolistService;
    private final TaskService taskService;
    private final CategoryRepository categoryRepository;
    private final AppUserRepository appUserRepository;

    @GetMapping
    public String list(@RequestParam(value = "authId", required = false) String authId,
                       @RequestParam(value = "selectedTodolistId", required = false) Integer selectedTodolistId,
                       @RequestParam(value = "categoryId", required = false) Integer categoryId,
                       @RequestParam(value = "state", required = false) String state,
                       @RequestParam(value = "search", required = false) String search,
                       Model model) {
        if (authId == null || authId.isBlank()) {
            return "redirect:/ui/auth/login";
        }

        var currentUser = appUserRepository.findByAuthId(UUID.fromString(authId))
            .orElse(null);
        var currentUserName = currentUser == null
            ? "User"
            : ((currentUser.getName() != null && !currentUser.getName().isBlank())
                ? currentUser.getName()
                : currentUser.getEmail());

        List<TodolistResponse> lists = todolistService.listTodolists(authId);
        var privateLists = lists.stream()
            .filter(list -> list.listType() == null || !"public".equalsIgnoreCase(list.listType()))
            .toList();
        var publicLists = lists.stream()
            .filter(list -> "public".equalsIgnoreCase(list.listType()))
            .toList();

        if (selectedTodolistId == null && !lists.isEmpty()) {
            selectedTodolistId = lists.getFirst().todolistId();
        }

        final Integer activeTodolistId = selectedTodolistId;

        TodolistResponse selectedList = null;
        List<cz.uhk.pro2.tulipani.web.dto.TaskResponse> tasks = List.of();
        if (activeTodolistId != null) {
            selectedList = lists.stream()
                .filter(list -> activeTodolistId.equals(list.todolistId()))
                .findFirst()
                .orElse(null);
            tasks = taskService.listTasksForTodolist(activeTodolistId, authId, categoryId, state, search);
        }

        List<Category> categories = categoryRepository.findAll();
        Map<Integer, Category> categoriesById = categories.stream()
            .filter(category -> category.getCategoryId() != null)
            .collect(Collectors.toMap(Category::getCategoryId, category -> category));

        model.addAttribute("lists", lists);
        model.addAttribute("privateLists", privateLists);
        model.addAttribute("publicLists", publicLists);
        model.addAttribute("selectedList", selectedList);
        model.addAttribute("selectedTodolistId", activeTodolistId);
        model.addAttribute("selectedCategoryId", categoryId);
        model.addAttribute("selectedState", state);
        model.addAttribute("search", search);
        model.addAttribute("tasks", tasks);
        model.addAttribute("categories", categories);
        model.addAttribute("categoriesById", categoriesById);
        model.addAttribute("currentUserName", currentUserName);
        model.addAttribute("currentUserEmail", currentUser != null ? currentUser.getEmail() : null);
        model.addAttribute("createTaskRequest", new CreateTaskRequest("", null, LocalDateTime.now(), activeTodolistId, null));
        model.addAttribute("createRequest", new CreateTodolistRequest("", "private"));
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
        return "redirect:/ui/todolists?authId=" + authId + "&selectedTodolistId=" + id;
    }

    @PostMapping("/tasks")
    public String createTask(@RequestParam(value = "authId", required = false) String authId,
                             @RequestParam(value = "name") String name,
                             @RequestParam(value = "description", required = false) String description,
                             @RequestParam(value = "deadline", required = false) String deadline,
                             @RequestParam(value = "selectedTodolistId", required = false) Integer selectedTodolistId,
                             @RequestParam(value = "categoryId", required = false) Integer categoryId) {
        var parsedDeadline = (deadline == null || deadline.isBlank())
            ? null
            : LocalDateTime.parse(deadline, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
        taskService.createTask(new CreateTaskRequest(name, description, parsedDeadline, selectedTodolistId, categoryId), authId);
        return redirectToDashboard(authId, selectedTodolistId, null, null, null);
    }

    @PostMapping("/categories")
    public String createCategory(@RequestParam(value = "authId", required = false) String authId,
                                 @RequestParam(value = "name") String name,
                                 @RequestParam(value = "colorHex", required = false) String colorHex,
                                 @RequestParam(value = "selectedTodolistId", required = false) Integer selectedTodolistId,
                                 @RequestParam(value = "categoryId", required = false) Integer categoryId,
                                 @RequestParam(value = "state", required = false) String state,
                                 @RequestParam(value = "search", required = false) String search) {
        var category = Category.builder()
            .name(name)
            .colorHex(colorHex)
            .build();
        categoryRepository.save(category);
        return redirectToDashboard(authId, selectedTodolistId, categoryId, state, search);
    }

    @PostMapping("/{taskId}/state")
    public String changeTaskState(@RequestParam(value = "authId", required = false) String authId,
                                  @org.springframework.web.bind.annotation.PathVariable Integer taskId,
                                  @RequestParam("state") String state,
                                  @RequestParam(value = "selectedTodolistId", required = false) Integer selectedTodolistId,
                                  @RequestParam(value = "categoryId", required = false) Integer categoryId,
                                  @RequestParam(value = "search", required = false) String search) {
        taskService.updateTaskStatus(taskId, new UpdateTaskStatusRequest(state), authId);
        return redirectToDashboard(authId, selectedTodolistId, categoryId, state, search);
    }

    private String redirectToDashboard(String authId,
                                       Integer selectedTodolistId,
                                       Integer categoryId,
                                       String state,
                                       String search) {
        var redirect = new StringBuilder("redirect:/ui/todolists");
        boolean first = true;
        if (authId != null && !authId.isBlank()) {
            redirect.append(first ? '?' : '&').append("authId=").append(authId);
            first = false;
        }
        if (selectedTodolistId != null) {
            redirect.append(first ? '?' : '&').append("selectedTodolistId=").append(selectedTodolistId);
            first = false;
        }
        if (categoryId != null) {
            redirect.append(first ? '?' : '&').append("categoryId=").append(categoryId);
            first = false;
        }
        if (state != null && !state.isBlank()) {
            redirect.append(first ? '?' : '&').append("state=").append(state);
            first = false;
        }
        if (search != null && !search.isBlank()) {
            redirect.append(first ? '?' : '&').append("search=").append(search);
        }
        return redirect.toString();
    }
}
