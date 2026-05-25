package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
}