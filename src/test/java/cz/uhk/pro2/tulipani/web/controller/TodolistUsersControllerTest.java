package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.service.TodolistService;
import cz.uhk.pro2.tulipani.web.dto.AddUserToTodolistRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TodolistUsersControllerTest {

    private MockMvc mockMvc;

    @Mock
    private TodolistService todolistService;

    @InjectMocks
    private TodolistUsersController controller;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new cz.uhk.pro2.tulipani.web.exception.GlobalExceptionHandler())
                .build();
    }

    @Test
    void listMembers_returnsOk() throws Exception {
        var tu = new cz.uhk.pro2.tulipani.domain.entity.TodolistUser();
        tu.setTodolistUsersId(1L);
        tu.setUserId(11L);
        tu.setRoleId(2L);
        tu.setIsListCreator(false);

        when(todolistService.getTodolistMembers(5L)).thenReturn(List.of(tu));

        mockMvc.perform(get("/api/todolists/5/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].userId").value(11));
    }

    @Test
    void addUser_returnsCreated() throws Exception {
        AddUserToTodolistRequest req = new AddUserToTodolistRequest(12L, 3L);
        doNothing().when(todolistService).addUserToTodolist(5L, 12L, 3L);

        mockMvc.perform(post("/api/todolists/5/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());
    }

    @Test
    void updateUserRole_returnsOk() throws Exception {
        AddUserToTodolistRequest req = new AddUserToTodolistRequest(12L, 4L);
        doNothing().when(todolistService).changeUserRoleInTodolist(5L, 12L, 4L);

        mockMvc.perform(put("/api/todolists/5/users/12")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk());
    }

    @Test
    void removeUser_returnsNoContent() throws Exception {
        doNothing().when(todolistService).removeUserFromTodolist(5L, 12L);

        mockMvc.perform(delete("/api/todolists/5/users/12"))
                .andExpect(status().isNoContent());
    }
}

