#!/bin/bash

# Complete Setup and Run Script for SpinWish Development
echo "🚀 Setting up and running SpinWish with local PostgreSQL..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo ""
echo -e "${BLUE}=== SpinWish Development Setup ===${NC}"
echo ""

# Step 1: Check PostgreSQL
print_status "Checking PostgreSQL status..."
if systemctl is-active --quiet postgresql; then
    print_success "PostgreSQL is running"
else
    print_warning "PostgreSQL is not running, starting it..."
    sudo systemctl start postgresql
    if [ $? -eq 0 ]; then
        print_success "PostgreSQL started"
    else
        print_error "Failed to start PostgreSQL"
        exit 1
    fi
fi

# Step 2: Setup Database
print_status "Setting up database and user..."

# Create SQL commands
sudo -u postgres psql << 'EOF'
-- Drop existing database and user if they exist
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

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO spinwish_user;
GRANT CREATE ON SCHEMA public TO spinwish_user;

-- Grant default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO spinwish_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO spinwish_user;
EOF

if [ $? -eq 0 ]; then
    print_success "Database setup completed"
else
    print_error "Database setup failed"
    exit 1
fi

# Step 3: Test Connection
print_status "Testing database connection..."
PGPASSWORD=spinwish_password psql -h localhost -U spinwish_user -d spinwish_dev -c "SELECT 'Connection successful!' as status;" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "Database connection test passed"
else
    print_error "Database connection test failed"
    exit 1
fi

# Step 4: Start Spring Boot Application
print_status "Starting Spring Boot application with local PostgreSQL..."
echo ""
echo -e "${YELLOW}Database Configuration:${NC}"
echo "  Host: localhost:5432"
echo "  Database: spinwish_dev"
echo "  Username: spinwish_user"
echo "  Profile: local"
echo ""

cd backend
print_status "Running: ./mvnw spring-boot:run -Dspring-boot.run.profiles=local"
echo ""

# Start the application
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
