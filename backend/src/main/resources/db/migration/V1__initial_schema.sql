-- Initial schema baseline
-- This file serves as a baseline for existing database schema
-- Flyway will skip this if tables already exist

-- Create roles table if not exists
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create users table if not exists
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    bio TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    credits INTEGER DEFAULT 0,
    followers INTEGER DEFAULT 0,
    instagram_handle VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_live BOOLEAN DEFAULT false,
    profile_image VARCHAR(255),
    rating DOUBLE PRECISION DEFAULT 0.0,
    role_id UUID REFERENCES roles(id)
);

-- Create other existing tables if not exists
CREATE TABLE IF NOT EXISTS profile (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone_number VARCHAR(255),
    image_url VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Insert default roles if not exists
INSERT INTO roles (id, role_name, created_at, updated_at) 
VALUES 
    (gen_random_uuid(), 'CLIENT', NOW(), NOW()),
    (gen_random_uuid(), 'DJ', NOW(), NOW()),
    (gen_random_uuid(), 'ADMIN', NOW(), NOW())
ON CONFLICT (role_name) DO NOTHING;
