package com.example.producer.controller;

import com.example.producer.model.User;
import com.example.producer.service.KafkaProducerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final KafkaProducerService kafkaProducerService;

    public UserController(KafkaProducerService kafkaProducerService) {
        this.kafkaProducerService = kafkaProducerService;
    }

    @PostMapping
    public ResponseEntity<String> createUser(@RequestBody User user) {
        kafkaProducerService.sendMessage(user);
        return ResponseEntity.ok("User message sent to Kafka successfully!");
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Producer Service is running!");
    }
}
