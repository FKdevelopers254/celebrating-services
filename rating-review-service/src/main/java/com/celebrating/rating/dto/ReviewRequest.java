package com.celebrating.rating.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.UUID;

@Data
public class ReviewRequest {
    @NotNull(message = "Post ID is required")
    private UUID postId;
    
    @NotBlank(message = "Content is required")
    @Size(min = 10, message = "Review content must be at least 10 characters")
    private String content;
} 