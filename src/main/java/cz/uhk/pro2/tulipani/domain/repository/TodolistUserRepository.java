package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.TodolistUser;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TodolistUserRepository extends JpaRepository<TodolistUser, Long> {
}