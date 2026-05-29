package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.TaskUser;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskUserRepository extends JpaRepository<TaskUser, Long> {

	boolean existsByTaskIdAndUserId(Long taskId, Long userId);

	Optional<TaskUser> findByTaskIdAndUserId(Long taskId, Long userId);

	List<TaskUser> findByTaskId(Long taskId);
}