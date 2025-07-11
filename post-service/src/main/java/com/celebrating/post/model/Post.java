package com.celebrating.post.model;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Table("posts")
public class Post {
    @Id
    private Long id;
    private UUID userId;
    private String title;
    private String content;
    private CelebrationType celebrationType;
    // List of image/media URLs returned from /api/posts/upload-media
    private List<String> mediaUrls;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private PostStatus status;
    private int likesCount;
    private int commentsCount;
}