package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class DemoApplicationTests {

    @Test
    void contextLoads() {
        // Sanity check: Spring context starts cleanly.
        // Jenkins/Actions will fail the build here before anything is scanned or shipped.
    }
}
