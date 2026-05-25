package cz.uhk.pro2.tulipani.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "todolist", schema = "public")
public class Todolist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "todolist_id")
    private Long todolistId;

    @Column(nullable = false)
    private String name;

    @Column(name = "list_type")
    private String listType;
}