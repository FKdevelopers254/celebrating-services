package com.celebrate.moderation;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

@RestController
@RequestMapping("/api/v1/moderation")
public class ModerationController {
    @GetMapping("/test")
    public ResponseEntity<String> testGet() {
        return ResponseEntity.ok("Moderation GET endpoint is working!");
    }

    @PostMapping("/test")
    public ResponseEntity<String> testPost() {
        return new ResponseEntity<>("Moderation POST endpoint is working!", HttpStatus.CREATED);
    }
} 