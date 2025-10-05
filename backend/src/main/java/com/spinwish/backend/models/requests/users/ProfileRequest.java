package com.spinwish.backend.models.requests.users;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class ProfileRequest {
    private String phoneNumber;
    private String firstName;
    private String lastName;
    private MultipartFile image;
}
