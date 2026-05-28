package cz.uhk.pro2.tulipani.service;

import cz.uhk.pro2.tulipani.domain.entity.AppUser;
import cz.uhk.pro2.tulipani.domain.entity.GroupRole;
import cz.uhk.pro2.tulipani.domain.entity.Todolist;
import cz.uhk.pro2.tulipani.domain.entity.TodolistUser;
import cz.uhk.pro2.tulipani.domain.repository.AppUserRepository;
import cz.uhk.pro2.tulipani.domain.repository.GroupRoleRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistRepository;
import cz.uhk.pro2.tulipani.domain.repository.TodolistUserRepository;
import cz.uhk.pro2.tulipani.web.dto.CreateTodolistRequest;
import cz.uhk.pro2.tulipani.web.dto.TodolistResponse;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TodolistServiceTest {

    @Mock
    private TodolistRepository todolistRepository;

    @Mock
    private TodolistUserRepository todolistUserRepository;

    @Mock
    private AppUserRepository appUserRepository;

    @Mock
    private GroupRoleRepository groupRoleRepository;

    @InjectMocks
    private TodolistService todolistService;

    @Test
    void createTodolist_savesListAndMembership() {
        var authId = "auth-123";
        var user = AppUser.builder().userId(10L).authId(authId).email("u@example.com").build();

        when(appUserRepository.findByAuthId(authId)).thenReturn(Optional.of(user));

        var savedList = Todolist.builder().todolistId(5L).name("My List").listType("personal").build();
        when(todolistRepository.save(any(Todolist.class))).thenReturn(savedList);

        var role = GroupRole.builder().roleId(1L).roleName("spravce").build();
        when(groupRoleRepository.findAll()).thenReturn(List.of(role));

        when(todolistUserRepository.save(any(TodolistUser.class))).thenAnswer(i -> i.getArgument(0));

        var req = new CreateTodolistRequest("My List", "personal");
        TodolistResponse resp = todolistService.createTodolist(req, authId);

        assertThat(resp).isNotNull();
        assertThat(resp.todolistId()).isEqualTo(5L);
        assertThat(resp.name()).isEqualTo("My List");

        verify(todolistRepository).save(any(Todolist.class));
        verify(todolistUserRepository).save(any(TodolistUser.class));
    }

    @Test
    void listTodolists_returnsUserLists() {
        var authId = "auth-123";
        var user = AppUser.builder().userId(10L).authId(authId).email("u@example.com").build();
        when(appUserRepository.findByAuthId(authId)).thenReturn(Optional.of(user));

        var todolist = Todolist.builder().todolistId(2L).name("Team").listType("team").build();
        var membership = TodolistUser.builder().todolistId(2L).userId(10L).todolist(todolist).build();
        when(todolistUserRepository.findByUserId(10L)).thenReturn(List.of(membership));

        var result = todolistService.listTodolists(authId);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).todolistId()).isEqualTo(2L);
        assertThat(result.get(0).name()).isEqualTo("Team");
    }
}
