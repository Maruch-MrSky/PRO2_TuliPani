package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.TodolistUser;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TodolistUserRepository extends JpaRepository<TodolistUser, Integer> {

	List<TodolistUser> findByUserId(Integer userId);

	boolean existsByTodolistIdAndUserId(Integer todolistId, Integer userId);

	java.util.Optional<TodolistUser> findByTodolistIdAndUserId(Integer todolistId, Integer userId);

}