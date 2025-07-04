package com.celebrating.userservice.events;

import com.celebrating.common.events.BaseEvent;

public class UserEvent extends BaseEvent {
    private final String userId;
    private final String action;
    private final Object data;

    public UserEvent(String userId, String action, Object data) {
        super("USER_EVENT");
        this.userId = userId;
        this.action = action;
        this.data = data;
    }

    public String getUserId() {
        return userId;
    }

    public String getAction() {
        return action;
    }

    public Object getData() {
        return data;
    }

    public static UserEvent userCreated(String userId, Object userData) {
        return new UserEvent(userId, "USER_CREATED", userData);
    }

    public static UserEvent userUpdated(String userId, Object userData) {
        return new UserEvent(userId, "USER_UPDATED", userData);
    }

    public static UserEvent userDeleted(String userId) {
        return new UserEvent(userId, "USER_DELETED", null);
    }
} 