package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.domain.repository.AuditLogRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private TaskUserRepository taskUserRepository;

    @Mock
    private TodolistRepository todolistRepository;

    @Mock
    private cz.uhk.pro2.tulipani.domain.repository.TodolistUserRepository todolistUserRepository;

    @Mock
    private AppUserRepository appUserRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private AuditLogRepository auditLogRepository;

    @InjectMocks
    private TaskService taskService;

    @Test
    void createTask_savesTaskAndAudit() {
        var authId = "auth-1";
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(20L).authId(authId).email("u@example.com").build();

        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(user));

        var todolist = cz.uhk.pro2.tulipani.domain.entity.Todolist.builder().todolistId(2L).name("Team").build();
        when(todolistRepository.findById(2L)).thenReturn(java.util.Optional.of(todolist));

        var saved = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(7L).name("Demo task").description("TODO").deadline(LocalDate.now()).state("todo").todolistId(2L).categoryId(1L).taskCreator(20L).updatedBy(20L).build();
        when(taskRepository.save(any(cz.uhk.pro2.tulipani.domain.entity.Task.class))).thenReturn(saved);

        when(categoryRepository.findById(1L)).thenReturn(java.util.Optional.of(new cz.uhk.pro2.tulipani.domain.entity.Category()));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        var req = new CreateTaskRequest("Demo task", "TODO", LocalDate.now(), 2L, 1L);
        var resp = taskService.createTask(req, authId);

        org.assertj.core.api.Assertions.assertThat(resp).isNotNull();
        org.assertj.core.api.Assertions.assertThat(resp.taskId()).isEqualTo(7L);

        verify(taskRepository).save(any(cz.uhk.pro2.tulipani.domain.entity.Task.class));
        verify(auditLogRepository).save(any());
    }

    @Test
    void getTask_returnsTaskData() {
        var authId = "auth-2";
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(30L).authId(authId).email("u2@example.com").build();

        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(user));

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(11L).name("Existing").description("Desc").deadline(LocalDate.now()).state("in_progress").todolistId(3L).categoryId(2L).taskCreator(30L).updatedBy(30L).build();
        when(taskRepository.findById(11L)).thenReturn(java.util.Optional.of(task));

        var resp = taskService.getTask(11L, authId);

        org.assertj.core.api.Assertions.assertThat(resp).isNotNull();
        org.assertj.core.api.Assertions.assertThat(resp.taskId()).isEqualTo(11L);
        org.assertj.core.api.Assertions.assertThat(resp.name()).isEqualTo("Existing");
    }

    @Test
    void assignUserToTask_addsMembershipAndAudit() {
        var taskId = 5L;
        var userId = 40L;
        var actorAuth = "actor-1";

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(taskId).name("T").todolistId(10L).build();
        when(taskRepository.findById(taskId)).thenReturn(java.util.Optional.of(task));
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(userId).authId("a").build();
        when(appUserRepository.findById(userId)).thenReturn(java.util.Optional.of(user));

        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(100L).authId(actorAuth).build();
        when(appUserRepository.findByAuthId(actorAuth)).thenReturn(java.util.Optional.of(actor));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(10L).userId(100L).isListCreator(true).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(10L, 100L)).thenReturn(java.util.Optional.of(membership));

        when(taskUserRepository.existsByTaskIdAndUserId(taskId, userId)).thenReturn(false);
        when(taskUserRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        taskService.assignUserToTask(actorAuth, taskId, userId);

        verify(taskUserRepository).save(any());
        verify(auditLogRepository).save(any());
    }

    @Test
    void unassignUserFromTask_deletesMembershipAndAudit() {
        var taskId = 6L;
        var userId = 50L;
        var actorAuth = "actor-2";

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(taskId).todolistId(20L).build();
        when(taskRepository.findById(taskId)).thenReturn(java.util.Optional.of(task));

        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(userId).authId(actorAuth).build();
        when(appUserRepository.findByAuthId(actorAuth)).thenReturn(java.util.Optional.of(actor));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(20L).userId(userId).isListCreator(false).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(20L, userId)).thenReturn(java.util.Optional.of(membership));

        var tu = cz.uhk.pro2.tulipani.domain.entity.TaskUser.builder().taskUsersId(99L).taskId(taskId).userId(userId).build();
        when(taskUserRepository.findByTaskIdAndUserId(taskId, userId)).thenReturn(java.util.Optional.of(tu));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        taskService.unassignUserFromTask(actorAuth, taskId, userId);

        verify(taskUserRepository).delete(tu);
        verify(auditLogRepository).save(any());
    }
}