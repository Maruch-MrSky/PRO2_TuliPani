package cz.uhk.pro2.tulipani.domain.repository;

import cz.uhk.pro2.tulipani.domain.entity.Attachment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttachmentRepository extends JpaRepository<Attachment, Long> {
}