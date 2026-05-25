package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.TaskUser;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskUserRepository extends JpaRepository<TaskUser, Long> {
}