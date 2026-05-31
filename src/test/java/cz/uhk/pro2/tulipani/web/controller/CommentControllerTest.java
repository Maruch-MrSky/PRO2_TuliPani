package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.web.dto.CreateCommentRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class CommentControllerTest {

    private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(new CommentController())
                .setControllerAdvice(new cz.uhk.pro2.tulipani.web.exception.GlobalExceptionHandler())
                .build();
    }

    @Test
    void addComment_notImplemented_returns501() throws Exception {
        CreateCommentRequest req = new CreateCommentRequest("Hello");

        mockMvc.perform(post("/api/tasks/1/comments")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isNotImplemented());
    }
}

