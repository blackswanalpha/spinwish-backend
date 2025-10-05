-- PostgreSQL Setup Commands for SpinWish Development
-- Run these commands in PostgreSQL as the postgres user

-- Create database
CREATE DATABASE spinwish_dev;

-- Create user
CREATE USER spinwish_user WITH PASSWORD 'spinwish_password';

-- Grant privileges on database
GRANT ALL PRIVILEGES ON DATABASE spinwish_dev TO spinwish_user;

-- Connect to the new database
\c spinwish_dev

-- Grant schema privileges (required for PostgreSQL 15+)
GRANT ALL ON SCHEMA public TO spinwish_user;
GRANT CREATE ON SCHEMA public TO spinwish_user;

-- Grant default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO spinwish_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO spinwish_user;

-- Verify the setup
\l
\du
