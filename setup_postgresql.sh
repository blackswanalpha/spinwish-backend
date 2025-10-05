#!/bin/bash

# PostgreSQL Setup Script for SpinWish Development
echo "Setting up PostgreSQL for SpinWish development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== PostgreSQL Setup for SpinWish ===${NC}"
echo ""

# Check if PostgreSQL is running
echo -e "${YELLOW}Step 1: Checking PostgreSQL status...${NC}"
if systemctl is-active --quiet postgresql; then
    echo -e "${GREEN}✓ PostgreSQL service is running${NC}"
else
    echo -e "${RED}✗ PostgreSQL service is not running${NC}"
    echo "Starting PostgreSQL..."
    sudo systemctl start postgresql
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PostgreSQL started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start PostgreSQL${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}Step 2: Creating database and user...${NC}"

# Create a temporary SQL file
cat > /tmp/spinwish_setup.sql << 'EOF'
-- Drop existing database and user if they exist (for clean setup)
DROP DATABASE IF EXISTS spinwish_dev;
DROP USER IF EXISTS spinwish_user;

-- Create database
CREATE DATABASE spinwish_dev;

-- Create user
CREATE USER spinwish_user WITH PASSWORD 'spinwish_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE spinwish_dev TO spinwish_user;

-- Connect to the new database
\c spinwish_dev

-- Grant schema privileges (for PostgreSQL 15+)
GRANT ALL ON SCHEMA public TO spinwish_user;
GRANT CREATE ON SCHEMA public TO spinwish_user;

-- Grant default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO spinwish_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO spinwish_user;

-- List databases to confirm
\l

-- List users to confirm
\du
EOF

# Execute the SQL file
echo "Executing database setup commands..."
sudo -u postgres psql -f /tmp/spinwish_setup.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database and user created successfully!${NC}"
    # Clean up temporary file
    rm -f /tmp/spinwish_setup.sql
else
    echo -e "${RED}✗ Failed to create database and user${NC}"
    rm -f /tmp/spinwish_setup.sql
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 3: Testing connection...${NC}"

# Test connection
PGPASSWORD=spinwish_password psql -h localhost -U spinwish_user -d spinwish_dev -c "SELECT version();" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Connection test successful!${NC}"
else
    echo -e "${RED}✗ Connection test failed${NC}"
    echo "Trying to diagnose the issue..."

    # Try to connect and show any error
    echo "Testing connection with detailed output:"
    PGPASSWORD=spinwish_password psql -h localhost -U spinwish_user -d spinwish_dev -c "SELECT version();"
    exit 1
fi

echo ""
echo -e "${GREEN}=== PostgreSQL setup completed successfully! ===${NC}"
echo ""
echo -e "${BLUE}Database Details:${NC}"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: spinwish_dev"
echo "  Username: spinwish_user"
echo "  Password: spinwish_password"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Your Spring Boot application is configured to use this database"
echo "2. Run: cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local"
echo ""
echo -e "${YELLOW}Starting your Spring Boot application now...${NC}"
