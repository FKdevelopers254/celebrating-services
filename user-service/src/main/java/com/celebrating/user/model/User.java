package com.celebrating.user.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.ZonedDateTime;
import java.util.UUID;
import org.hibernate.annotations.GenericGenerator;

@Data
@NoArgsConstructor
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(generator = "UUID")
    @org.hibernate.annotations.GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    private String bio;
    private String location;

    @Column(name = "profile_image_url")
    private String profileImageUrl;

    @Column(name = "is_private")
    private boolean isPrivate;

    @Column(name = "is_verified")
    private boolean isVerified;

    @Column(name = "is_active")
    private boolean isActive;

    @Column(name = "created_at")
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;
    @Column(name = "last_login")
    private ZonedDateTime lastLogin;

    @PrePersist
    public void ensureId() {
        if (id == null) {
            id = java.util.UUID.randomUUID();
        }
    }

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private UserStats stats;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private CelebrityProfile celebrityProfile;
} 