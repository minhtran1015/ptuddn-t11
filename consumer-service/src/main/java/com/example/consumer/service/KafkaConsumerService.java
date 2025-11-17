package com.example.consumer.service;

import com.example.consumer.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class KafkaConsumerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerService.class);
    
    private final List<User> receivedUsers = new ArrayList<>();

    @KafkaListener(topics = "${kafka.topic.name}", groupId = "${spring.kafka.consumer.group-id}")
    public void consume(User user) {
        logger.info("Received message from Kafka: {}", user);
        receivedUsers.add(user);
        
        // Xử lý business logic ở đây
        processUser(user);
    }

    private void processUser(User user) {
        logger.info("Processing user: ID={}, Name={}, Email={}", 
                user.getId(), user.getName(), user.getEmail());
        // Thêm logic xử lý dữ liệu ở đây
    }

    public List<User> getReceivedUsers() {
        return new ArrayList<>(receivedUsers);
    }
}
