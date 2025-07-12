package com.celebrating.post.controller;

import com.celebrating.post.model.Post;
import com.celebrating.post.model.Comment;
import com.celebrating.post.model.Like;
import com.celebrating.post.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.Map;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.codec.multipart.FilePart;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {
    private final PostService postService;
    private static final Logger logger = LoggerFactory.getLogger(PostController.class);

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<Post> createPost(@Valid @RequestBody Post post) {
        return postService.createPost(post);
    }

    @PutMapping("/{id}")
    public Mono<Post> updatePost(@PathVariable Long id, @Valid @RequestBody Post post) {
        return postService.updatePost(id, post);
    }

    @GetMapping("/{id}")
    public Mono<Post> getPost(@PathVariable Long id) {
        return postService.getPost(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deletePost(@PathVariable Long id) {
        return postService.deletePost(id);
    }

    @GetMapping("/user/{userId}")
    public Flux<Post> getUserPosts(@PathVariable UUID userId) {
        return postService.getUserPosts(userId);
    }

    @GetMapping
    public Flux<Post> getRecentPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return postService.getRecentPosts(page, size);
    }

    @GetMapping("/type/{celebrationType}")
    public Flux<Post> getPostsByCelebrationType(@PathVariable String celebrationType) {
        return postService.getPostsByCelebrationType(celebrationType);
    }

    @PostMapping("/{postId}/comments")
    public Mono<Comment> addComment(@PathVariable Long postId, @Valid @RequestBody Comment comment) {
        comment.setPostId(postId);
        return postService.addComment(comment);
    }

    @DeleteMapping("/comments/{commentId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteComment(@PathVariable Long commentId) {
        return postService.deleteComment(commentId);
    }

    @GetMapping("/{postId}/comments")
    public Flux<Comment> getPostComments(@PathVariable Long postId) {
        return postService.getPostComments(postId);
    }

    @PostMapping("/{postId}/like")
    public Mono<Like> likePost(@PathVariable Long postId, @RequestParam UUID userId) {
        return postService.likePost(postId, userId);
    }

    @DeleteMapping("/{postId}/like")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> unlikePost(@PathVariable Long postId, @RequestParam UUID userId) {
        return postService.unlikePost(postId, userId);
    }

    @GetMapping("/{postId}/likes")
    public Flux<Like> getPostLikes(@PathVariable Long postId) {
        return postService.getPostLikes(postId);
    }

    @PostMapping("/upload-media")
    public Mono<ResponseEntity<Map<String, String>>> uploadMedia(@RequestPart("media") Mono<FilePart> filePartMono) {
        return filePartMono.flatMap(filePart -> {
            String uploadDir = System.getProperty("java.io.tmpdir") + "/post-uploads/";
            try {
            Files.createDirectories(Paths.get(uploadDir));
                String filename = UUID.randomUUID() + "_" + filePart.filename();
            Path filePath = Paths.get(uploadDir, filename);
                return filePart.transferTo(filePath)
                    .thenReturn(ResponseEntity.ok().body(Map.of("mediaUrl", "/uploads/" + filename)));
        } catch (Exception e) {
                logger.error("Failed to upload file", e);
                return Mono.just(ResponseEntity.status(500).body(Map.of("error", "Failed to upload file: " + e.getMessage())));
        }
        }).switchIfEmpty(Mono.just(ResponseEntity.badRequest().body(Map.of("error", "No file uploaded or file is empty"))));
    }
}