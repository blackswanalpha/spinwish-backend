-- V3__populate_sample_data.sql
-- Populate database with sample DJs and songs for testing

-- First, ensure we have the required tables and roles
INSERT INTO roles (id, role_name, created_at, updated_at) 
VALUES 
    (gen_random_uuid(), 'DJ', NOW(), NOW())
ON CONFLICT (role_name) DO NOTHING;

-- Insert sample artists first (required for songs)
INSERT INTO artists (id, artist_name, artist_bio, artist_profile, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Stellar Waves', 'Afro-Electronic music collective from Nairobi', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440002', 'Rhythm Collective', 'High-energy Afrobeats group', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440003', 'Urban Pulse', 'Contemporary African hip-hop artists', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440004', 'Savanna Sounds', 'Traditional meets modern fusion', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440005', 'Neon Nights', 'Electronic dance music producers', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert sample DJ users
INSERT INTO users (
    id, username, email_address, password, bio, profile_image, 
    rating, followers, is_live, instagram_handle, is_active, 
    email_verified, phone_verified, role_id, created_at, updated_at
) VALUES
    (
        '550e8400-e29b-41d4-a716-446655440101',
        'dj_nexus',
        'dj.nexus@spinwish.com',
        '$2a$10$example.hash.for.password123',
        'Electronic music producer and DJ with 8+ years of experience. Specializing in progressive house, techno, and ambient soundscapes. Known for creating immersive audio journeys that transport listeners to another dimension.',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop&crop=face',
        4.8,
        2847,
        true,
        '@dj_nexus_official',
        true,
        true,
        true,
        (SELECT id FROM roles WHERE role_name = 'DJ' LIMIT 1),
        NOW(),
        NOW()
    ),
    (
        '550e8400-e29b-41d4-a716-446655440102',
        'rhythm_queen',
        'rhythm.queen@spinwish.com',
        '$2a$10$example.hash.for.password123',
        'Afrobeats sensation bringing the heat from Lagos to the world. Known for infectious rhythms and crowd-moving performances. Resident DJ at top clubs across East Africa.',
        'https://images.unsplash.com/photo-1494790108755-2616c0763c5e?w=400&h=400&fit=crop&crop=face',
        4.9,
        3521,
        false,
        '@rhythm_queen_ke',
        true,
        true,
        true,
        (SELECT id FROM roles WHERE role_name = 'DJ' LIMIT 1),
        NOW(),
        NOW()
    ),
    (
        '550e8400-e29b-41d4-a716-446655440103',
        'bass_master',
        'bass.master@spinwish.com',
        '$2a$10$example.hash.for.password123',
        'Deep house and bass music specialist. Creating underground vibes that make you move. 10+ years in the scene with releases on major labels.',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        4.7,
        1892,
        true,
        '@bass_master_ke',
        true,
        true,
        true,
        (SELECT id FROM roles WHERE role_name = 'DJ' LIMIT 1),
        NOW(),
        NOW()
    ),
    (
        '550e8400-e29b-41d4-a716-446655440104',
        'afro_fusion',
        'afro.fusion@spinwish.com',
        '$2a$10$example.hash.for.password123',
        'Blending traditional African sounds with modern electronic beats. Cultural ambassador through music, bringing authentic African vibes to global audiences.',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
        4.6,
        2156,
        false,
        '@afro_fusion_dj',
        true,
        true,
        true,
        (SELECT id FROM roles WHERE role_name = 'DJ' LIMIT 1),
        NOW(),
        NOW()
    ),
    (
        '550e8400-e29b-41d4-a716-446655440105',
        'urban_vibes',
        'urban.vibes@spinwish.com',
        '$2a$10$example.hash.for.password123',
        'Hip-hop and R&B curator with a passion for discovering new talent. Known for seamless mixing and reading the crowd perfectly. Festival regular and radio host.',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
        4.5,
        1743,
        true,
        '@urban_vibes_dj',
        true,
        true,
        true,
        (SELECT id FROM roles WHERE role_name = 'DJ' LIMIT 1),
        NOW(),
        NOW()
    )
ON CONFLICT (id) DO NOTHING;

-- Insert DJ genres
INSERT INTO user_genres (user_id, genre) VALUES
    ('550e8400-e29b-41d4-a716-446655440101', 'Electronic'),
    ('550e8400-e29b-41d4-a716-446655440101', 'House'),
    ('550e8400-e29b-41d4-a716-446655440101', 'Techno'),
    ('550e8400-e29b-41d4-a716-446655440101', 'Progressive'),
    ('550e8400-e29b-41d4-a716-446655440101', 'Ambient'),
    
    ('550e8400-e29b-41d4-a716-446655440102', 'Afrobeats'),
    ('550e8400-e29b-41d4-a716-446655440102', 'Dancehall'),
    ('550e8400-e29b-41d4-a716-446655440102', 'Reggae'),
    ('550e8400-e29b-41d4-a716-446655440102', 'Amapiano'),
    
    ('550e8400-e29b-41d4-a716-446655440103', 'Deep House'),
    ('550e8400-e29b-41d4-a716-446655440103', 'Bass'),
    ('550e8400-e29b-41d4-a716-446655440103', 'Underground'),
    ('550e8400-e29b-41d4-a716-446655440103', 'Minimal'),
    
    ('550e8400-e29b-41d4-a716-446655440104', 'Afro-Fusion'),
    ('550e8400-e29b-41d4-a716-446655440104', 'World Music'),
    ('550e8400-e29b-41d4-a716-446655440104', 'Traditional'),
    ('550e8400-e29b-41d4-a716-446655440104', 'Electronic'),
    
    ('550e8400-e29b-41d4-a716-446655440105', 'Hip-Hop'),
    ('550e8400-e29b-41d4-a716-446655440105', 'R&B'),
    ('550e8400-e29b-41d4-a716-446655440105', 'Urban'),
    ('550e8400-e29b-41d4-a716-446655440105', 'Trap')
ON CONFLICT DO NOTHING;
