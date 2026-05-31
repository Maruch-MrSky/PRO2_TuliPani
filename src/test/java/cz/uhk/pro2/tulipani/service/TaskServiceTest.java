package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.CategoryRepository;
import cz.uhk.pro2.tulipani.domain.repository.GroupRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskRepository;
import cz.uhk.pro2.tulipani.domain.repository.TaskUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.domain.repository.AuditLogRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTaskRequest;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import java.util.UUID;
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
    private GroupRoleRepository groupRoleRepository;

    @Mock
    private AuditLogRepository auditLogRepository;

    @InjectMocks
    private TaskService taskService;

    @Test
    void createTask_savesTaskAndAudit() {
        var authId = UUID.randomUUID();
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(20).authId(authId).email("u@example.com").build();

        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(user));

        var todolist = cz.uhk.pro2.tulipani.domain.entity.Todolist.builder().todolistId(2).name("Team").build();
        when(todolistRepository.findById(2)).thenReturn(java.util.Optional.of(todolist));

        var saved = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(7).name("Demo task").description("TODO").deadline(LocalDateTime.now()).state("todo").todolistId(2).categoryId(1).taskCreator(20).updatedBy(authId.toString()).build();
        when(taskRepository.save(any(cz.uhk.pro2.tulipani.domain.entity.Task.class))).thenReturn(saved);

        when(categoryRepository.findById(1)).thenReturn(java.util.Optional.of(new cz.uhk.pro2.tulipani.domain.entity.Category()));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        var req = new CreateTaskRequest("Demo task", "TODO", LocalDateTime.now(), 2, 1);
        var resp = taskService.createTask(req, authId.toString());

        org.assertj.core.api.Assertions.assertThat(resp).isNotNull();
        org.assertj.core.api.Assertions.assertThat(resp.taskId()).isEqualTo(7);

        verify(taskRepository).save(any(cz.uhk.pro2.tulipani.domain.entity.Task.class));
        verify(auditLogRepository).save(any());
    }

    @Test
    void listTasksForTodolist_filtersByCategoryAndSearch() {
        var authId = UUID.randomUUID();
        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(21).authId(authId).email("viewer@example.com").build();
        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(actor));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(9).userId(21).isListCreator(true).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(9, 21)).thenReturn(java.util.Optional.of(membership));

        var matching = cz.uhk.pro2.tulipani.domain.entity.Task.builder()
            .taskId(1)
            .name("Write dashboard")
            .description("Create dashboard cards")
            .todolistId(9)
            .categoryId(4)
            .state("todo")
            .updatedBy(authId.toString())
            .build();
        var other = cz.uhk.pro2.tulipani.domain.entity.Task.builder()
            .taskId(2)
            .name("Ignore me")
            .description("Different category")
            .todolistId(9)
            .categoryId(7)
            .state("done")
            .updatedBy(authId.toString())
            .build();

        when(taskRepository.findByTodolistId(9)).thenReturn(java.util.List.of(matching, other));

        var tasks = taskService.listTasksForTodolist(9, authId.toString(), 4, "todo", "dashboard");

        org.assertj.core.api.Assertions.assertThat(tasks).hasSize(1);
        org.assertj.core.api.Assertions.assertThat(tasks.getFirst().taskId()).isEqualTo(1);
    }

    @Test
    void getTask_returnsTaskData() {
        var authId = UUID.randomUUID();
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(30).authId(authId).email("u2@example.com").build();

        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(user));

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(11).name("Existing").description("Desc").deadline(LocalDateTime.now()).state("in_progress").todolistId(3).categoryId(2).taskCreator(30).updatedBy(authId.toString()).build();
        when(taskRepository.findById(11)).thenReturn(java.util.Optional.of(task));

        var resp = taskService.getTask(11, authId.toString());

        org.assertj.core.api.Assertions.assertThat(resp).isNotNull();
        org.assertj.core.api.Assertions.assertThat(resp.taskId()).isEqualTo(11);
        org.assertj.core.api.Assertions.assertThat(resp.name()).isEqualTo("Existing");
    }

    @Test
    void assignUserToTask_addsMembershipAndAudit() {
        var taskId = 5;
        var userId = 40;
        var actorAuth = UUID.randomUUID();

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(taskId).name("T").todolistId(10).build();
        when(taskRepository.findById(taskId)).thenReturn(java.util.Optional.of(task));
        var user = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(userId).authId(UUID.randomUUID()).build();
        when(appUserRepository.findById(userId)).thenReturn(java.util.Optional.of(user));

        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(100).authId(actorAuth).build();
        when(appUserRepository.findByAuthId(actorAuth)).thenReturn(java.util.Optional.of(actor));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(10).userId(100).isListCreator(true).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(10, 100)).thenReturn(java.util.Optional.of(membership));

        when(taskUserRepository.existsByTaskIdAndUserId(taskId, userId)).thenReturn(false);
        when(taskUserRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        taskService.assignUserToTask(actorAuth.toString(), taskId, userId);

        verify(taskUserRepository).save(any());
        verify(auditLogRepository).save(any());
    }

    @Test
    void unassignUserFromTask_deletesMembershipAndAudit() {
        var taskId = 6;
        var userId = 50;
        var actorAuth = UUID.randomUUID();

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(taskId).todolistId(20).build();
        when(taskRepository.findById(taskId)).thenReturn(java.util.Optional.of(task));

        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(userId).authId(actorAuth).build();
        when(appUserRepository.findByAuthId(actorAuth)).thenReturn(java.util.Optional.of(actor));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(20).userId(userId).isListCreator(false).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(20, userId)).thenReturn(java.util.Optional.of(membership));

        var tu = cz.uhk.pro2.tulipani.domain.entity.TaskUser.builder().taskUsersId(99).taskId(taskId).userId(userId).build();
        when(taskUserRepository.findByTaskIdAndUserId(taskId, userId)).thenReturn(java.util.Optional.of(tu));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        taskService.unassignUserFromTask(actorAuth.toString(), taskId, userId);

        verify(taskUserRepository).delete(tu);
        verify(auditLogRepository).save(any());
    }

    @Test
    void updateTaskStatus_allowsAuthorizedUser() {
        var authId = UUID.randomUUID();
        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(60).authId(authId).build();
        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(actor));

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(70).name("S").todolistId(30).taskCreator(60).state("todo").build();
        when(taskRepository.findById(70)).thenReturn(java.util.Optional.of(task));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(30).userId(60).isListCreator(true).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(30, 60)).thenReturn(java.util.Optional.of(membership));

        when(groupRoleRepository.findAll()).thenReturn(java.util.List.of(cz.uhk.pro2.tulipani.domain.entity.GroupRole.builder().roleId(1).roleName("spravce").build()));

        when(taskRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        var req = new cz.uhk.pro2.tulipani.web.dto.UpdateTaskStatusRequest("in_progress");
        var resp = taskService.updateTaskStatus(70, req, authId.toString());

        org.assertj.core.api.Assertions.assertThat(resp).isNotNull();
        org.assertj.core.api.Assertions.assertThat(resp.state()).isEqualTo("in_progress");
        verify(auditLogRepository).save(any());
    }

    @Test
    void deleteTask_allowsAuthorizedUser() {
        var authId = UUID.randomUUID();
        var actor = cz.uhk.pro2.tulipani.domain.entity.AppUser.builder().userId(80).authId(authId).build();
        when(appUserRepository.findByAuthId(authId)).thenReturn(java.util.Optional.of(actor));

        var task = cz.uhk.pro2.tulipani.domain.entity.Task.builder().taskId(81).todolistId(40).taskCreator(80).build();
        when(taskRepository.findById(81)).thenReturn(java.util.Optional.of(task));

        var membership = cz.uhk.pro2.tulipani.domain.entity.TodolistUser.builder().todolistId(40).userId(80).isListCreator(true).build();
        when(todolistUserRepository.findByTodolistIdAndUserId(40, 80)).thenReturn(java.util.Optional.of(membership));

        when(groupRoleRepository.findAll()).thenReturn(java.util.List.of(cz.uhk.pro2.tulipani.domain.entity.GroupRole.builder().roleId(1).roleName("spravce").build()));

        when(taskUserRepository.findByTaskId(81)).thenReturn(java.util.List.of());
        when(auditLogRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        taskService.deleteTask(81, authId.toString());

        verify(taskRepository).delete(task);
        verify(auditLogRepository).save(any());
    }
}