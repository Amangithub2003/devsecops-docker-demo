package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/")
    public Map<String, Object> hello() {
        return Map.of(
                "message", "Hello from the DevSecOps/GitOps demo app!",
                "version", "1.0.0",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/api/status")
    public Map<String, String> status() {
        return Map.of("status", "UP");
    }
}
