#!/bin/bash

# Smart Startup Script for SpinWish Backend
# Automatically detects available databases and uses the best option

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print status
print_header() {
    echo ""
    echo -e "${PURPLE}=== $1 ===${NC}"
    echo ""
}

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

print_trying() {
    echo -e "${CYAN}[TRYING]${NC} $1"
}

# Function to test database connection
test_postgres_connection() {
    local host=$1
    local port=$2
    local database=$3
    local username=$4
    local password=$5
    
    print_trying "Testing PostgreSQL connection to $host:$port/$database"
    
    # Test connection with timeout
    PGPASSWORD="$password" timeout 10 psql -h "$host" -p "$port" -U "$username" -d "$database" -c "SELECT 1;" > /dev/null 2>&1
    return $?
}

# Function to test local PostgreSQL setup
test_local_postgres_setup() {
    print_trying "Checking if local PostgreSQL user exists"
    
    # Check if user exists
    sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='spinwish_user';" 2>/dev/null | grep -q 1
    local user_exists=$?
    
    if [ $user_exists -eq 0 ]; then
        print_success "Local PostgreSQL user exists"
        return 0
    else
        print_warning "Local PostgreSQL user does not exist"
        return 1
    fi
}

# Function to setup local PostgreSQL
setup_local_postgres() {
    print_status "Setting up local PostgreSQL database and user..."
    
    # Create database and user
    sudo -u postgres psql << 'EOF' > /dev/null 2>&1
DROP DATABASE IF EXISTS spinwish_dev;
DROP USER IF EXISTS spinwish_user;
CREATE DATABASE spinwish_dev;
CREATE USER spinwish_user WITH PASSWORD 'spinwish_password';
GRANT ALL PRIVILEGES ON DATABASE spinwish_dev TO spinwish_user;
\c spinwish_dev
GRANT ALL ON SCHEMA public TO spinwish_user;
GRANT CREATE ON SCHEMA public TO spinwish_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO spinwish_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO spinwish_user;
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Local PostgreSQL setup completed"
        return 0
    else
        print_error "Local PostgreSQL setup failed"
        return 1
    fi
}

# Function to start application with specific profile
start_application() {
    local profile=$1
    local db_type=$2
    
    print_status "Starting SpinWish Backend with profile: $profile ($db_type)"
    echo ""
    
    cd backend
    ./mvnw spring-boot:run -Dspring-boot.run.profiles="$profile"
}

# Main execution
print_header "SpinWish Smart Database Detection & Startup"

print_status "Detecting available database options..."

# Database connection parameters
REMOTE_HOST="dpg-d1ulgcemcj7s73el4o9g-a.oregon-postgres.render.com"
REMOTE_PORT="5432"
REMOTE_DB="spinwish"
REMOTE_USER="spinwish_user"
REMOTE_PASS="XvoPi9gDsXd2xw81RmQHBKVonIlrC7q5"

LOCAL_HOST="localhost"
LOCAL_PORT="5432"
LOCAL_DB="spinwish_dev"
LOCAL_USER="spinwish_user"
LOCAL_PASS="spinwish_password"

# Test remote PostgreSQL first
print_status "Option 1: Testing remote PostgreSQL (Render)..."
if test_postgres_connection "$REMOTE_HOST" "$REMOTE_PORT" "$REMOTE_DB" "$REMOTE_USER" "$REMOTE_PASS"; then
    print_success "Remote PostgreSQL is available!"
    print_status "Using remote PostgreSQL for production-like development"
    start_application "prod" "Remote PostgreSQL"
    exit 0
else
    print_warning "Remote PostgreSQL is not available (network/server issue)"
fi

# Test local PostgreSQL
print_status "Option 2: Testing local PostgreSQL..."
if systemctl is-active --quiet postgresql; then
    print_success "Local PostgreSQL service is running"
    
    # Check if local setup exists
    if test_local_postgres_setup; then
        # Test connection
        if test_postgres_connection "$LOCAL_HOST" "$LOCAL_PORT" "$LOCAL_DB" "$LOCAL_USER" "$LOCAL_PASS"; then
            print_success "Local PostgreSQL is available and configured!"
            print_status "Using local PostgreSQL for development"
            start_application "local" "Local PostgreSQL"
            exit 0
        else
            print_warning "Local PostgreSQL connection failed"
        fi
    else
        print_status "Local PostgreSQL needs setup"
        if setup_local_postgres; then
            if test_postgres_connection "$LOCAL_HOST" "$LOCAL_PORT" "$LOCAL_DB" "$LOCAL_USER" "$LOCAL_PASS"; then
                print_success "Local PostgreSQL setup and connection successful!"
                print_status "Using local PostgreSQL for development"
                start_application "local" "Local PostgreSQL"
                exit 0
            else
                print_error "Local PostgreSQL setup completed but connection still fails"
            fi
        else
            print_error "Failed to setup local PostgreSQL"
        fi
    fi
else
    print_warning "Local PostgreSQL service is not running"
    print_status "Attempting to start PostgreSQL service..."
    
    if sudo systemctl start postgresql 2>/dev/null; then
        print_success "PostgreSQL service started"
        # Retry local setup
        if setup_local_postgres && test_postgres_connection "$LOCAL_HOST" "$LOCAL_PORT" "$LOCAL_DB" "$LOCAL_USER" "$LOCAL_PASS"; then
            print_success "Local PostgreSQL is now available!"
            start_application "local" "Local PostgreSQL"
            exit 0
        fi
    else
        print_warning "Could not start PostgreSQL service"
    fi
fi

# Fallback to H2
print_status "Option 3: Falling back to H2 in-memory database"
print_warning "Using H2 - data will not persist between restarts"
print_status "H2 Console will be available at: http://localhost:8080/h2-console"
start_application "dev" "H2 In-Memory Database"
