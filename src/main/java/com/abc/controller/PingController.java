package com.abc.controller;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;


@RestController
@EnableWebMvc
public class PingController {
    @RequestMapping(path = "/ping", method = RequestMethod.GET)
    public Map<String, String> ping() {
        Map<String, String> ping = new HashMap<>();
        ping.put("pong", "Hello, World!");
        return ping;
    }

    @GetMapping("/checking")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("API is running at " + Instant.now());
    }
}
