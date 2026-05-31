package cz.uhk.pro2.tulipani.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.FetchType;
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
@Table(name = "app_user", schema = "public")
public class AppUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Integer userId;

    @Column
    private String email;

    @Column
    private String name;

    @Column
    private String surname;

    @Column(name = "auth_id")
    private String authId;

    @Column(name = "app_role_id")
    private Integer appRoleId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "app_role_id", insertable = false, updatable = false)
    private AppRole appRole;
}