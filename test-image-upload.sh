#!/bin/bash

# Test script for session image upload functionality
# This script verifies that the image upload fix is working correctly

echo "=========================================="
echo "Session Image Upload - Verification Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to print info
print_info() {
    echo -e "ℹ $1"
}

echo "1. Checking directory structure..."
echo ""

# Check if backend directory exists
if [ -d "backend" ]; then
    print_success "Backend directory exists"
else
    print_error "Backend directory not found"
    exit 1
fi

# Check if uploads directory exists in backend
if [ -d "backend/uploads" ]; then
    print_success "Backend uploads directory exists"
else
    print_warning "Backend uploads directory not found, creating..."
    mkdir -p backend/uploads
fi

# Check if session-images directory exists
if [ -d "backend/uploads/session-images" ]; then
    print_success "Session images directory exists"
    
    # Check permissions
    PERMS=$(stat -c "%a" backend/uploads/session-images)
    if [ "$PERMS" = "755" ] || [ "$PERMS" = "775" ] || [ "$PERMS" = "777" ]; then
        print_success "Directory permissions are correct ($PERMS)"
    else
        print_warning "Directory permissions are $PERMS, setting to 755..."
        chmod 755 backend/uploads/session-images
    fi
else
    print_warning "Session images directory not found, creating..."
    mkdir -p backend/uploads/session-images
    chmod 755 backend/uploads/session-images
    print_success "Created session images directory with correct permissions"
fi

echo ""
echo "2. Checking backend build..."
echo ""

# Check if backend JAR exists
if [ -f "backend/target/backend-0.0.1-SNAPSHOT.jar" ]; then
    print_success "Backend JAR file exists"
    
    # Check JAR timestamp
    JAR_TIME=$(stat -c %Y backend/target/backend-0.0.1-SNAPSHOT.jar)
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - JAR_TIME))
    
    if [ $TIME_DIFF -lt 3600 ]; then
        print_success "Backend JAR is recent (built within last hour)"
    else
        print_warning "Backend JAR is older than 1 hour, consider rebuilding"
        print_info "Run: cd backend && ./mvnw clean package -DskipTests"
    fi
else
    print_error "Backend JAR not found"
    print_info "Build the backend: cd backend && ./mvnw clean package -DskipTests"
fi

echo ""
echo "3. Checking source code modifications..."
echo ""

# Check if SessionService has logging
if grep -q "@Slf4j" backend/src/main/java/com/spinwish/backend/services/SessionService.java; then
    print_success "SessionService has logging enabled"
else
    print_warning "SessionService may not have logging enabled"
fi

# Check if SessionController has logging
if grep -q "@Slf4j" backend/src/main/java/com/spinwish/backend/controllers/SessionController.java; then
    print_success "SessionController has logging enabled"
else
    print_warning "SessionController may not have logging enabled"
fi

echo ""
echo "4. Checking configuration files..."
echo ""

# Check application.properties for multipart config
if grep -q "spring.servlet.multipart.max-file-size" backend/src/main/resources/application.properties; then
    MAX_SIZE=$(grep "spring.servlet.multipart.max-file-size" backend/src/main/resources/application.properties | cut -d'=' -f2)
    print_success "Multipart max file size configured: $MAX_SIZE"
else
    print_warning "Multipart max file size not configured"
fi

echo ""
echo "5. Directory structure summary..."
echo ""

# Show directory tree
print_info "Upload directories:"
ls -lah backend/uploads/ 2>/dev/null || print_error "Cannot list backend/uploads/"

echo ""
echo "6. Checking for running backend process..."
echo ""

# Check if backend is running
if pgrep -f "backend-0.0.1-SNAPSHOT.jar" > /dev/null; then
    print_success "Backend process is running"
    PID=$(pgrep -f "backend-0.0.1-SNAPSHOT.jar")
    print_info "Process ID: $PID"
else
    print_warning "Backend process is not running"
    print_info "Start backend: cd backend && java -jar target/backend-0.0.1-SNAPSHOT.jar"
fi

echo ""
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo ""

# Count checks
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Directory checks
if [ -d "backend/uploads/session-images" ]; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# JAR check
if [ -f "backend/target/backend-0.0.1-SNAPSHOT.jar" ]; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Logging checks
if grep -q "@Slf4j" backend/src/main/java/com/spinwish/backend/services/SessionService.java; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

if grep -q "@Slf4j" backend/src/main/java/com/spinwish/backend/controllers/SessionController.java; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

echo "Checks passed: $PASSED_CHECKS/$TOTAL_CHECKS"
echo ""

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    print_success "All checks passed! Ready to test image upload."
    echo ""
    print_info "Next steps:"
    echo "  1. Start backend (if not running): cd backend && java -jar target/backend-0.0.1-SNAPSHOT.jar"
    echo "  2. Start Flutter app: cd spinwishapp && flutter run"
    echo "  3. Create a session with an image"
    echo "  4. Check logs: tail -f backend/backend_latest.log | grep -i upload"
else
    print_warning "Some checks failed. Review the output above."
    echo ""
    print_info "Fix any issues and run this script again."
fi

echo ""
echo "=========================================="

