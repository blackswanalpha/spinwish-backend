#!/bin/bash

# SpinWish Cron Jobs Installation and Setup Script
# This script installs and configures automated server management cron jobs

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/spinwish-cron.conf"
CRONTAB_ENTRIES="$SCRIPT_DIR/crontab-entries.txt"
BACKUP_DIR="$PROJECT_ROOT/backups/cron"

# Functions for colored output
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

print_question() {
    echo -e "${CYAN}[QUESTION]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if running as root (not recommended)
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. It's recommended to run as a regular user."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check if cron is installed and running
    if ! command -v crontab &> /dev/null; then
        print_error "crontab command not found. Please install cron."
        exit 1
    fi
    
    if ! systemctl is-active --quiet cron 2>/dev/null && ! systemctl is-active --quiet crond 2>/dev/null; then
        print_warning "Cron service doesn't appear to be running."
        print_status "Attempting to start cron service..."
        
        if sudo systemctl start cron 2>/dev/null || sudo systemctl start crond 2>/dev/null; then
            print_success "Cron service started"
        else
            print_error "Failed to start cron service. Please start it manually."
            exit 1
        fi
    fi
    
    # Check if project structure is correct
    if [ ! -f "$PROJECT_ROOT/smart_start.sh" ] && [ ! -f "$PROJECT_ROOT/start.sh" ]; then
        print_error "SpinWish startup scripts not found in $PROJECT_ROOT"
        print_error "Please run this script from the correct project directory"
        exit 1
    fi
    
    # Check if backend directory exists
    if [ ! -d "$PROJECT_ROOT/backend" ]; then
        print_error "Backend directory not found in $PROJECT_ROOT"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Function to create necessary directories
create_directories() {
    print_header "Creating Directories"
    
    local dirs=(
        "$PROJECT_ROOT/logs"
        "$PROJECT_ROOT/logs/cron"
        "$BACKUP_DIR"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        else
            print_status "Directory already exists: $dir"
        fi
    done
    
    print_success "Directory structure created"
}

# Function to set proper permissions
set_permissions() {
    print_header "Setting Permissions"
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR/spinwish-server-manager.sh"
    chmod +x "$SCRIPT_DIR/log-manager.sh"
    chmod +x "$SCRIPT_DIR/install-cron-jobs.sh"
    
    # Set proper permissions for config file
    chmod 644 "$CONFIG_FILE"
    
    # Set permissions for log directories
    chmod 755 "$PROJECT_ROOT/logs"
    chmod 755 "$PROJECT_ROOT/logs/cron"
    
    print_success "Permissions set correctly"
}

# Function to backup existing crontab
backup_crontab() {
    print_header "Backing Up Existing Crontab"
    
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/crontab_backup_$timestamp.txt"
    
    if crontab -l > "$backup_file" 2>/dev/null; then
        print_success "Existing crontab backed up to: $backup_file"
    else
        print_status "No existing crontab found (this is normal for first-time setup)"
        touch "$backup_file"
    fi
}

# Function to configure cron jobs
configure_cron_jobs() {
    print_header "Configuring Cron Jobs"
    
    # Load configuration
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    print_question "Select cron job configuration:"
    echo "1) Production (every 3 minutes + maintenance)"
    echo "2) Development (every 10 minutes + cleanup)"
    echo "3) Custom (choose your own intervals)"
    echo "4) Manual (I'll configure manually)"
    
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            install_production_cron
            ;;
        2)
            install_development_cron
            ;;
        3)
            install_custom_cron
            ;;
        4)
            show_manual_instructions
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install production cron jobs
install_production_cron() {
    print_status "Installing production cron configuration..."
    
    local temp_cron=$(mktemp)
    
    # Get existing crontab
    crontab -l > "$temp_cron" 2>/dev/null || true
    
    # Add SpinWish cron jobs
    cat >> "$temp_cron" << EOF

# SpinWish Server Management - Production Configuration
# Generated on $(date)

# Primary monitoring every 3 minutes
*/3 * * * * cd $PROJECT_ROOT && ./cron-scripts/spinwish-server-manager.sh cron >> logs/cron/cron-execution.log 2>&1

# Daily maintenance at 2:30 AM
30 2 * * * cd $PROJECT_ROOT && ./cron-scripts/log-manager.sh full-maintenance >> logs/cron/maintenance.log 2>&1

# Weekly restart on Sunday at 3:00 AM
0 3 * * 0 cd $PROJECT_ROOT && ./cron-scripts/spinwish-server-manager.sh restart >> logs/cron/weekly-restart.log 2>&1

# Boot-time startup
@reboot cd $PROJECT_ROOT && sleep 60 && ./cron-scripts/spinwish-server-manager.sh start >> logs/cron/boot-start.log 2>&1

EOF
    
    # Install new crontab
    crontab "$temp_cron"
    rm "$temp_cron"
    
    print_success "Production cron jobs installed"
}

# Function to install development cron jobs
install_development_cron() {
    print_status "Installing development cron configuration..."
    
    local temp_cron=$(mktemp)
    
    # Get existing crontab
    crontab -l > "$temp_cron" 2>/dev/null || true
    
    # Add SpinWish cron jobs
    cat >> "$temp_cron" << EOF

# SpinWish Server Management - Development Configuration
# Generated on $(date)

# Monitor every 10 minutes
*/10 * * * * cd $PROJECT_ROOT && ./cron-scripts/spinwish-server-manager.sh cron >> logs/cron/cron-execution.log 2>&1

# Daily log cleanup at 2:00 AM
0 2 * * * cd $PROJECT_ROOT && ./cron-scripts/log-manager.sh cleanup >> logs/cron/cleanup.log 2>&1

# Boot-time startup
@reboot cd $PROJECT_ROOT && sleep 30 && ./cron-scripts/spinwish-server-manager.sh start >> logs/cron/boot-start.log 2>&1

EOF
    
    # Install new crontab
    crontab "$temp_cron"
    rm "$temp_cron"
    
    print_success "Development cron jobs installed"
}

# Function to install custom cron jobs
install_custom_cron() {
    print_status "Custom cron configuration..."
    
    print_question "Select monitoring interval:"
    echo "1) Every 3 minutes (high frequency)"
    echo "2) Every 5 minutes (standard)"
    echo "3) Every 10 minutes (light)"
    echo "4) Every 15 minutes (minimal)"
    
    read -p "Enter choice (1-4): " interval_choice
    
    local interval
    case $interval_choice in
        1) interval="*/3 * * * *" ;;
        2) interval="*/5 * * * *" ;;
        3) interval="*/10 * * * *" ;;
        4) interval="*/15 * * * *" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
    
    print_question "Enable weekly restart? (y/N): "
    read -n 1 -r weekly_restart
    echo
    
    print_question "Enable boot-time startup? (Y/n): "
    read -n 1 -r boot_startup
    echo
    
    local temp_cron=$(mktemp)
    crontab -l > "$temp_cron" 2>/dev/null || true
    
    cat >> "$temp_cron" << EOF

# SpinWish Server Management - Custom Configuration
# Generated on $(date)

# Server monitoring
$interval cd $PROJECT_ROOT && ./cron-scripts/spinwish-server-manager.sh cron >> logs/cron/cron-execution.log 2>&1

# Daily maintenance at 2:30 AM
30 2 * * * cd $PROJECT_ROOT && ./cron-scripts/log-manager.sh full-maintenance >> logs/cron/maintenance.log 2>&1

EOF
    
    if [[ $weekly_restart =~ ^[Yy]$ ]]; then
        echo "# Weekly restart on Sunday at 3:00 AM" >> "$temp_cron"
        echo "0 3 * * 0 cd $PROJECT_ROOT && ./cron-scripts/spinwish-server-manager.sh restart >> logs/cron/weekly-restart.log 2>&1" >> "$temp_cron"
        echo "" >> "$temp_cron"
    fi
    
    if [[ ! $boot_startup =~ ^[Nn]$ ]]; then
        echo "# Boot-time startup" >> "$temp_cron"
        echo "@reboot cd $PROJECT_ROOT && sleep 60 && ./cron-scripts/spinwish-server-manager.sh start >> logs/cron/boot-start.log 2>&1" >> "$temp_cron"
        echo "" >> "$temp_cron"
    fi
    
    crontab "$temp_cron"
    rm "$temp_cron"
    
    print_success "Custom cron jobs installed"
}

# Function to show manual instructions
show_manual_instructions() {
    print_status "Manual configuration selected"
    print_status "Please refer to: $CRONTAB_ENTRIES"
    print_status "Use 'crontab -e' to edit your crontab manually"
    print_status "Replace '/path/to/spinwish' with: $PROJECT_ROOT"
}

# Function to test the installation
test_installation() {
    print_header "Testing Installation"
    
    # Test server manager script
    print_status "Testing server manager script..."
    if "$SCRIPT_DIR/spinwish-server-manager.sh" status; then
        print_success "Server manager script works correctly"
    else
        print_warning "Server manager script test completed (server may not be running)"
    fi
    
    # Test log manager script
    print_status "Testing log manager script..."
    if "$SCRIPT_DIR/log-manager.sh" summary; then
        print_success "Log manager script works correctly"
    else
        print_error "Log manager script test failed"
    fi
    
    # Show current crontab
    print_status "Current crontab entries:"
    crontab -l | grep -A 20 -B 5 "SpinWish" || print_status "No SpinWish entries found in crontab"
}

# Function to show post-installation information
show_post_install_info() {
    print_header "Installation Complete"
    
    print_success "SpinWish cron jobs have been successfully installed!"
    echo ""
    print_status "Configuration files:"
    echo "  - Server manager: $SCRIPT_DIR/spinwish-server-manager.sh"
    echo "  - Log manager: $SCRIPT_DIR/log-manager.sh"
    echo "  - Configuration: $CONFIG_FILE"
    echo ""
    print_status "Log files location:"
    echo "  - Cron execution: $PROJECT_ROOT/logs/cron/"
    echo ""
    print_status "Useful commands:"
    echo "  - View crontab: crontab -l"
    echo "  - Edit crontab: crontab -e"
    echo "  - Check server status: ./cron-scripts/spinwish-server-manager.sh status"
    echo "  - Manual server start: ./cron-scripts/spinwish-server-manager.sh start"
    echo "  - View logs: tail -f logs/cron/cron-execution.log"
    echo ""
    print_status "Next steps:"
    echo "  1. Monitor logs for the first few executions"
    echo "  2. Adjust configuration in $CONFIG_FILE if needed"
    echo "  3. Test server restart: ./cron-scripts/spinwish-server-manager.sh restart"
    echo ""
    print_warning "Note: The first cron execution will occur at the next scheduled interval."
    print_status "You can test immediately with: ./cron-scripts/spinwish-server-manager.sh cron"
}

# Main execution
main() {
    print_header "SpinWish Cron Jobs Installation"
    
    check_prerequisites
    create_directories
    set_permissions
    backup_crontab
    configure_cron_jobs
    test_installation
    show_post_install_info
}

# Run main function
main "$@"
