package com.celebrating.rating.repository;

import com.celebrating.rating.model.Review;
import com.celebrating.rating.model.ReviewStatus;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface ReviewRepository extends ReactiveCrudRepository<Review, Long> {
    
    @Query("SELECT * FROM reviews WHERE user_id = :userId AND post_id = :postId AND status = 'ACTIVE'")
    Mono<Review> findByUserIdAndPostId(UUID userId, UUID postId);
    
    @Query("SELECT * FROM reviews WHERE post_id = :postId AND status = 'ACTIVE' ORDER BY created_at DESC LIMIT :limit OFFSET :offset")
    Flux<Review> findByPostId(UUID postId, int limit, int offset);
    
    @Query("SELECT * FROM reviews WHERE user_id = :userId AND status = 'ACTIVE' ORDER BY created_at DESC")
    Flux<Review> findByUserId(UUID userId);
    
    @Query("SELECT COUNT(*) FROM reviews WHERE post_id = :postId AND status = 'ACTIVE'")
    Mono<Long> getReviewCountForPost(UUID postId);
    
    Flux<Review> findByStatus(ReviewStatus status);
} 