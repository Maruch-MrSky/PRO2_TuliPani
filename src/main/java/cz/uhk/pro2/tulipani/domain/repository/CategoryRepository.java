package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}