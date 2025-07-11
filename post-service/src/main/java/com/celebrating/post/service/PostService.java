package com.celebrating.post.service;

import com.celebrating.post.model.Post;
import com.celebrating.post.model.Comment;
import com.celebrating.post.model.Like;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

public interface PostService {
    Mono<Post> createPost(Post post);
    Mono<Post> updatePost(Long id, Post post);
    Mono<Post> getPost(Long id);
    Mono<Void> deletePost(Long id);
    Flux<Post> getUserPosts(UUID userId);
    Flux<Post> getRecentPosts(int page, int size);
    Flux<Post> getPostsByCelebrationType(String celebrationType);
    
    Mono<Comment> addComment(Comment comment);
    Mono<Void> deleteComment(Long commentId);
    Flux<Comment> getPostComments(Long postId);
    
    Mono<Like> likePost(Long postId, UUID userId);
    Mono<Void> unlikePost(Long postId, UUID userId);
    Flux<Like> getPostLikes(Long postId);
}