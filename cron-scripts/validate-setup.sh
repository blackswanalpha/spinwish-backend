#!/bin/bash

# SpinWish Cron Setup Validation Script
# This script validates that the cron job system is properly configured

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
    echo ""
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Validation functions
validate_files() {
    print_header "File Structure Validation"
    
    local required_files=(
        "cron-scripts/spinwish-server-manager.sh"
        "cron-scripts/log-manager.sh"
        "cron-scripts/spinwish-cron.conf"
        "cron-scripts/crontab-entries.txt"
        "cron-scripts/install-cron-jobs.sh"
        "smart_start.sh"
        "start.sh"
        "backend/pom.xml"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            check_pass "File exists: $file"
        else
            check_fail "Missing file: $file"
        fi
    done
}

validate_permissions() {
    print_header "Permissions Validation"
    
    local executable_files=(
        "cron-scripts/spinwish-server-manager.sh"
        "cron-scripts/log-manager.sh"
        "cron-scripts/install-cron-jobs.sh"
        "cron-scripts/validate-setup.sh"
        "smart_start.sh"
        "start.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [ -x "$PROJECT_ROOT/$file" ]; then
            check_pass "Executable: $file"
        else
            check_fail "Not executable: $file"
        fi
    done
}

validate_directories() {
    print_header "Directory Structure Validation"
    
    local required_dirs=(
        "logs"
        "logs/cron"
        "backend"
        "cron-scripts"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            check_pass "Directory exists: $dir"
        else
            check_fail "Missing directory: $dir"
            echo "  Run: mkdir -p $PROJECT_ROOT/$dir"
        fi
    done
}

validate_cron_service() {
    print_header "Cron Service Validation"
    
    if command -v crontab &> /dev/null; then
        check_pass "crontab command available"
    else
        check_fail "crontab command not found"
        echo "  Install cron: sudo apt-get install cron"
    fi
    
    if systemctl is-active --quiet cron 2>/dev/null || systemctl is-active --quiet crond 2>/dev/null; then
        check_pass "Cron service is running"
    else
        check_warn "Cron service may not be running"
        echo "  Start cron: sudo systemctl start cron"
    fi
}

validate_java_environment() {
    print_header "Java Environment Validation"
    
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1)
        check_pass "Java available: $java_version"
    else
        check_fail "Java not found"
        echo "  Install Java 17+: sudo apt-get install openjdk-17-jdk"
    fi
    
    if [ -f "$PROJECT_ROOT/backend/mvnw" ]; then
        check_pass "Maven wrapper available"
    else
        check_warn "Maven wrapper not found"
    fi
}

validate_configuration() {
    print_header "Configuration Validation"
    
    local config_file="$PROJECT_ROOT/cron-scripts/spinwish-cron.conf"
    
    if [ -f "$config_file" ]; then
        check_pass "Configuration file exists"
        
        # Check for required configuration values
        if grep -q "PROFILE=" "$config_file"; then
            check_pass "PROFILE setting found"
        else
            check_warn "PROFILE setting not found in config"
        fi
        
        if grep -q "SERVER_PORT=" "$config_file"; then
            check_pass "SERVER_PORT setting found"
        else
            check_warn "SERVER_PORT setting not found in config"
        fi
    else
        check_fail "Configuration file missing"
    fi
}

validate_scripts() {
    print_header "Script Functionality Validation"
    
    # Test server manager script
    if "$PROJECT_ROOT/cron-scripts/spinwish-server-manager.sh" status &>/dev/null; then
        check_pass "Server manager script executes"
    else
        local exit_code=$?
        if [ $exit_code -eq 1 ]; then
            check_pass "Server manager script executes (server not running)"
        else
            check_fail "Server manager script has errors"
        fi
    fi
    
    # Test log manager script
    if "$PROJECT_ROOT/cron-scripts/log-manager.sh" summary &>/dev/null; then
        check_pass "Log manager script executes"
    else
        check_fail "Log manager script has errors"
    fi
}

validate_crontab() {
    print_header "Crontab Validation"
    
    if crontab -l &>/dev/null; then
        local cron_entries=$(crontab -l 2>/dev/null | grep -c "spinwish\|SpinWish" || echo 0)
        
        if [ "$cron_entries" -gt 0 ]; then
            check_pass "SpinWish cron entries found ($cron_entries entries)"
        else
            check_warn "No SpinWish cron entries found"
            echo "  Run: ./cron-scripts/install-cron-jobs.sh"
        fi
    else
        check_warn "No crontab configured"
        echo "  Run: ./cron-scripts/install-cron-jobs.sh"
    fi
}

validate_network() {
    print_header "Network Validation"
    
    # Check if port 8080 is available or in use by our app
    if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
        check_warn "Port 8080 is in use (may be SpinWish server)"
    else
        check_pass "Port 8080 is available"
    fi
    
    # Test health endpoint if server is running
    if curl -s --max-time 5 "http://localhost:8080/actuator/health" &>/dev/null; then
        check_pass "Health endpoint accessible"
    else
        check_warn "Health endpoint not accessible (server may not be running)"
    fi
}

test_basic_functionality() {
    print_header "Basic Functionality Test"
    
    echo "Testing server manager commands..."
    
    # Test status command
    if "$PROJECT_ROOT/cron-scripts/spinwish-server-manager.sh" status &>/dev/null; then
        check_pass "Status command works"
    else
        check_warn "Status command completed with warnings"
    fi
    
    # Test log rotation
    if "$PROJECT_ROOT/cron-scripts/log-manager.sh" rotate &>/dev/null; then
        check_pass "Log rotation works"
    else
        check_fail "Log rotation failed"
    fi
}

generate_report() {
    print_header "Validation Summary"
    
    echo "Validation Results:"
    echo -e "  ${GREEN}Passed: $CHECKS_PASSED${NC}"
    echo -e "  ${RED}Failed: $CHECKS_FAILED${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""
    
    if [ $CHECKS_FAILED -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            echo -e "${GREEN}✓ All validations passed! Your cron setup is ready.${NC}"
        else
            echo -e "${YELLOW}⚠ Validation passed with warnings. Review warnings above.${NC}"
        fi
        echo ""
        echo "Next steps:"
        echo "1. Install cron jobs: ./cron-scripts/install-cron-jobs.sh"
        echo "2. Monitor logs: tail -f logs/cron/cron-execution.log"
        echo "3. Test manually: ./cron-scripts/spinwish-server-manager.sh cron"
    else
        echo -e "${RED}✗ Validation failed. Please fix the issues above before proceeding.${NC}"
        echo ""
        echo "Common fixes:"
        echo "1. Set permissions: chmod +x cron-scripts/*.sh"
        echo "2. Create directories: mkdir -p logs/cron"
        echo "3. Install dependencies: sudo apt-get install cron openjdk-17-jdk"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}SpinWish Cron Setup Validation${NC}"
    echo "Project root: $PROJECT_ROOT"
    echo ""
    
    validate_files
    validate_permissions
    validate_directories
    validate_cron_service
    validate_java_environment
    validate_configuration
    validate_scripts
    validate_crontab
    validate_network
    test_basic_functionality
    
    generate_report
}

# Run validation
main "$@"
