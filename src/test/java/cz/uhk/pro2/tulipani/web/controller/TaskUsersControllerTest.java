package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.web.dto.AssignUserToTaskRequest;
import cz.uhk.pro2.tulipani.service.TaskService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.util.List;

@WebMvcTest(TaskUsersController.class)
@AutoConfigureMockMvc(addFilters = false)
public class TaskUsersControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TaskService taskService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void assignUser_shouldReturnCreated() throws Exception {
        AssignUserToTaskRequest req = new AssignUserToTaskRequest(10L);
        doNothing().when(taskService).assignUserToTask("auth-1", 1L, 10L);

        mockMvc.perform(post("/api/tasks/1/users")
                .header("X-Auth-Id", "auth-1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
            .andExpect(status().isCreated());
    }

    @Test
    void unassignUser_shouldReturnNoContent() throws Exception {
        doNothing().when(taskService).unassignUserFromTask("auth-1", 1L, 10L);

        mockMvc.perform(delete("/api/tasks/1/users/10")
                .header("X-Auth-Id", "auth-1"))
            .andExpect(status().isNoContent());
    }

    @Test
    void listAssignedUsers_shouldReturnOk() throws Exception {
        var tu = new cz.uhk.pro2.tulipani.domain.entity.TaskUser();
        tu.setTaskUsersId(5L);
        tu.setUserId(10L);
        when(taskService.listUsersForTask(1L)).thenReturn(List.of(tu));

        mockMvc.perform(get("/api/tasks/1/users"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0]").value(10));
    }
}
