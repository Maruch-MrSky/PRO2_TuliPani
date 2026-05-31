package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.TaskUser;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskUserRepository extends JpaRepository<TaskUser, Integer> {

	boolean existsByTaskIdAndUserId(Integer taskId, Integer userId);

	Optional<TaskUser> findByTaskIdAndUserId(Integer taskId, Integer userId);

	List<TaskUser> findByTaskId(Integer taskId);
}