package com.celebrating.rating.service;

import com.celebrating.rating.dto.ReviewRequest;
import com.celebrating.rating.model.Review;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface ReviewService {
    Mono<Review> createReview(UUID userId, ReviewRequest request);
    Mono<Review> updateReview(UUID userId, Long reviewId, ReviewRequest request);
    Mono<Void> deleteReview(UUID userId, Long reviewId);
    Mono<Review> getUserPostReview(UUID userId, UUID postId);
    Flux<Review> getPostReviews(UUID postId, int page, int size);
    Flux<Review> getUserReviews(UUID userId);
    Mono<Long> getReviewCount(UUID postId);
    Mono<Review> likeReview(UUID userId, Long reviewId);
    Mono<Review> unlikeReview(UUID userId, Long reviewId);
} 