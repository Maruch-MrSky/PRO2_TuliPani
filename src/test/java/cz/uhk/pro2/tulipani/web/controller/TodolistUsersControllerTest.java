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
        tu.setTodolistUsersId((int) 1L);
        tu.setUserId((int) 11L);
        tu.setRoleId((int) 2L);
        tu.setIsListCreator(false);

        when(todolistService.getTodolistMembers((int) 5L)).thenReturn(List.of(tu));

        mockMvc.perform(get("/api/todolists/5/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].userId").value((int) 11L));
    }

    @Test
    void addUser_returnsCreated() throws Exception {
        AddUserToTodolistRequest req = new AddUserToTodolistRequest((int) 12L, (int) 3L);
        doNothing().when(todolistService).addUserToTodolist((int) 5L, (int) 12L, (int) 3L);

        mockMvc.perform(post("/api/todolists/5/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());
    }

    @Test
    void updateUserRole_returnsOk() throws Exception {
        AddUserToTodolistRequest req = new AddUserToTodolistRequest((int) 12L, (int) 4L);
        doNothing().when(todolistService).changeUserRoleInTodolist((int) 5L, (int) 12L, (int) 4L);

        mockMvc.perform(put("/api/todolists/5/users/12")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk());
    }

    @Test
    void removeUser_returnsNoContent() throws Exception {
        doNothing().when(todolistService).removeUserFromTodolist((int) 5L, (int) 12L);

        mockMvc.perform(delete("/api/todolists/5/users/12"))
                .andExpect(status().isNoContent());
    }
}

