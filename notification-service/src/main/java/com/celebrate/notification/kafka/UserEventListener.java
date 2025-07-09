package com.celebrate.notification.kafka;

import com.celebrating.common.events.UserEvent;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class UserEventListener {

    @KafkaListener(topics = "${kafka.topics.user-events}", groupId = "${spring.kafka.consumer.group-id}")
    public void handleUserEvent(UserEvent event) {
        System.out.println("Received user event: " + event.getEventId());
        
        switch (event.getAction()) {
            case "USER_CREATED":
                handleUserCreated(event);
                break;
            case "USER_UPDATED":
                handleUserUpdated(event);
                break;
            case "USER_DELETED":
                handleUserDeleted(event);
                break;
            default:
                System.out.println("Unknown user event action: " + event.getAction());
        }
    }

    private void handleUserCreated(UserEvent event) {
        // Create welcome notification
        System.out.println("Creating welcome notification for user: " + event.getUserId());
    }

    private void handleUserUpdated(UserEvent event) {
        // Handle profile update notifications if needed
        System.out.println("Handling profile update for user: " + event.getUserId());
    }

    private void handleUserDeleted(UserEvent event) {
        // Clean up notifications for deleted user
        System.out.println("Cleaning up notifications for deleted user: " + event.getUserId());
    }
} 