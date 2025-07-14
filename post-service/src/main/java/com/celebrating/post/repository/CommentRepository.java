package com.celebrating.post.repository;

import com.celebrating.post.model.Comment;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import reactor.core.publisher.Flux;

import java.util.UUID;

public interface CommentRepository extends R2dbcRepository<Comment, Long> {
    Flux<Comment> findByPostId(Long postId);
    Flux<Comment> findByUserId(UUID userId);
}