package com.spinwish.backend.services;

import com.spinwish.backend.entities.Users;
import com.spinwish.backend.security.JwtTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    public String generateToken(Users user) {
        return jwtTokenUtil.generateToken(user);
    }

    public String generateRefreshToken(Users user) {
        return jwtTokenUtil.generateRefreshToken(user);
    }
}
