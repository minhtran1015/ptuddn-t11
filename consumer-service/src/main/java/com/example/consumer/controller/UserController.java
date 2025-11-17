package com.example.consumer.controller;

import com.example.consumer.model.User;
import com.example.consumer.service.KafkaConsumerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final KafkaConsumerService kafkaConsumerService;

    public UserController(KafkaConsumerService kafkaConsumerService) {
        this.kafkaConsumerService = kafkaConsumerService;
    }

    @GetMapping("/received")
    public ResponseEntity<List<User>> getReceivedUsers() {
        return ResponseEntity.ok(kafkaConsumerService.getReceivedUsers());
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Consumer Service is running!");
    }
}
