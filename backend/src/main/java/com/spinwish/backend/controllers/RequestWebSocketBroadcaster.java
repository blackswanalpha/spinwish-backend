package com.spinwish.backend.controllers;

import com.spinwish.backend.models.responses.users.PlaySongResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class RequestWebSocketBroadcaster {

    private final SimpMessagingTemplate messagingTemplate;

    public void broadcastRequestUpdate(PlaySongResponse response) {
        messagingTemplate.convertAndSend("/topic/requests", response);
    }
}

