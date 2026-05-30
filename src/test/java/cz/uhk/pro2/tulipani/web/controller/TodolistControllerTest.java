package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.service.port.TodolistOperations;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import com.fasterxml.jackson.databind.ObjectMapper;

class TodolistControllerTest {

    private MockMvc mockMvc;

    @Mock
        private TodolistOperations todolistService;

    @InjectMocks
    private TodolistController todolistController;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(todolistController)
                .setControllerAdvice(new cz.uhk.pro2.tulipani.web.exception.GlobalExceptionHandler())
                .build();
    }

    @Test
    void listTodolists_returnsList() throws Exception {
        when(todolistService.listTodolists("auth-1"))
                .thenReturn(List.of(new TodolistResponse(1L, "List A", "personal")));

        mockMvc.perform(get("/api/todolists").header("X-Auth-Id", "auth-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].todolistId").value(1));
    }

    @Test
    void createTodolist_validRequest_returnsCreated() throws Exception {
        CreateTodolistRequest req = new CreateTodolistRequest("New list", "personal");
        when(todolistService.createTodolist(req, "auth-1"))
                .thenReturn(new TodolistResponse(2L, "New list", "personal"));

        mockMvc.perform(post("/api/todolists")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("X-Auth-Id", "auth-1")
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.todolistId").value(2));
    }
}
