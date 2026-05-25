package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.Todolist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TodolistRepository extends JpaRepository<Todolist, Long> {
}