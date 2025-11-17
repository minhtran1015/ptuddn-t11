package com.example.producer.service;

import com.example.producer.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class KafkaProducerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaProducerService.class);

    @Value("${kafka.topic.name}")
    private String topicName;

    private final KafkaTemplate<String, User> kafkaTemplate;

    public KafkaProducerService(KafkaTemplate<String, User> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendMessage(User user) {
        logger.info("Sending message to topic {}: {}", topicName, user);
        
        CompletableFuture<SendResult<String, User>> future = kafkaTemplate.send(topicName, user.getId().toString(), user);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                logger.info("Message sent successfully: [{}] with offset: [{}]", 
                        user, result.getRecordMetadata().offset());
            } else {
                logger.error("Unable to send message: [{}] due to: {}", user, ex.getMessage());
            }
        });
    }
}
