package com.spinwish.backend.models.requests.sessions;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Data
public class SessionImageRequest {
    private UUID sessionId;
    private MultipartFile image;
    private String description;
}

