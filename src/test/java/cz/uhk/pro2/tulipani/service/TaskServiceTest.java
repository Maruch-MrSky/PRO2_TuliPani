package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.assertThrows;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private TaskUserRepository taskUserRepository;

    @Mock
    private TodolistRepository todolistRepository;

    @Mock
    private AppUserRepository appUserRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private TaskService taskService;

    @Test
    void createTaskIsStillAStub() {
        CreateTaskRequest request = new CreateTaskRequest("Demo task", "TODO", LocalDate.now(), 1L, 1L);

        assertThrows(UnsupportedOperationException.class, () -> taskService.createTask(request, "auth-1"));
    }
}