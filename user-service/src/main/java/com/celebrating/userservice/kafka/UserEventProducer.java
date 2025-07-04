package com.celebrating.userservice.kafka;

import com.celebrating.common.events.UserEvent;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import java.util.concurrent.CompletableFuture;

@Service
public class UserEventProducer {

    private final KafkaTemplate<String, UserEvent> kafkaTemplate;
    private final String userEventsTopic;

    public UserEventProducer(
            KafkaTemplate<String, UserEvent> kafkaTemplate,
            @Value("${kafka.topics.user-events}") String userEventsTopic) {
        this.kafkaTemplate = kafkaTemplate;
        this.userEventsTopic = userEventsTopic;
    }

    public void sendUserCreatedEvent(String userId, Object userData) {
        UserEvent event = UserEvent.userCreated(userId, userData);
        sendUserEvent(userId, event);
    }

    public void sendUserUpdatedEvent(String userId, Object userData) {
        UserEvent event = UserEvent.userUpdated(userId, userData);
        sendUserEvent(userId, event);
    }

    public void sendUserDeletedEvent(String userId) {
        UserEvent event = UserEvent.userDeleted(userId);
        sendUserEvent(userId, event);
    }

    private void sendUserEvent(String userId, UserEvent event) {
        CompletableFuture<SendResult<String, UserEvent>> future = kafkaTemplate.send(userEventsTopic, userId, event);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                System.out.println("User event sent successfully: " + event.getEventType());
            } else {
                System.err.println("Failed to send user event: " + ex.getMessage());
            }
        });
    }
} 