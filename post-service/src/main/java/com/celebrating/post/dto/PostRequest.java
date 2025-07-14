package com.celebrating.post.dto;

import com.celebrating.post.model.CelebrationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class PostRequest {
    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 255, message = "Title must be between 3 and 255 characters")
    private String title;
    
    @NotBlank(message = "Content is required")
    @Size(min = 10, message = "Content must be at least 10 characters")
    private String content;
    
    @NotNull(message = "Celebration type is required")
    private CelebrationType celebrationType;
    
    @NotNull(message = "User ID is required")
    private UUID userId;
    
    private List<String> mediaUrls;
} 