#!/bin/bash

# SpinWish Log Management Script
# Handles log rotation, cleanup, and monitoring for cron jobs

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/spinwish-cron.conf"
LOG_DIR="$PROJECT_ROOT/logs/cron"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Default values
MAX_LOG_SIZE=${MAX_LOG_SIZE:-50}  # MB
LOG_RETENTION_COUNT=${LOG_RETENTION_COUNT:-10}
LOG_CLEANUP_DAYS=${LOG_CLEANUP_DAYS:-7}
ENABLE_LOG_CLEANUP=${ENABLE_LOG_CLEANUP:-true}

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to convert MB to bytes
mb_to_bytes() {
    echo $(($1 * 1024 * 1024))
}

# Function to get file size in bytes
get_file_size() {
    if [ -f "$1" ]; then
        stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Function to rotate a log file
rotate_log() {
    local log_file="$1"
    local max_count="$2"
    
    if [ ! -f "$log_file" ]; then
        return 0
    fi
    
    echo "Rotating log file: $log_file"
    
    # Remove oldest log if we're at the limit
    local oldest_log="${log_file}.${max_count}"
    if [ -f "$oldest_log" ]; then
        rm -f "$oldest_log"
    fi
    
    # Shift existing logs
    for ((i=max_count-1; i>=1; i--)); do
        local current_log="${log_file}.${i}"
        local next_log="${log_file}.$((i+1))"
        
        if [ -f "$current_log" ]; then
            mv "$current_log" "$next_log"
        fi
    done
    
    # Move current log to .1
    if [ -f "$log_file" ]; then
        mv "$log_file" "${log_file}.1"
        touch "$log_file"
        chmod 644 "$log_file"
    fi
}

# Function to check and rotate logs based on size
check_and_rotate_by_size() {
    local log_file="$1"
    local max_size_mb="$2"
    local retention_count="$3"
    
    if [ ! -f "$log_file" ]; then
        return 0
    fi
    
    local file_size=$(get_file_size "$log_file")
    local max_size_bytes=$(mb_to_bytes "$max_size_mb")
    
    if [ "$file_size" -gt "$max_size_bytes" ]; then
        echo "Log file $log_file exceeds ${max_size_mb}MB, rotating..."
        rotate_log "$log_file" "$retention_count"
        return 0
    fi
    
    return 1
}

# Function to cleanup old logs
cleanup_old_logs() {
    local cleanup_days="$1"
    
    echo "Cleaning up logs older than $cleanup_days days..."
    
    # Find and remove old log files
    find "$LOG_DIR" -name "*.log*" -type f -mtime +$cleanup_days -exec rm -f {} \;
    
    # Clean up empty directories
    find "$LOG_DIR" -type d -empty -delete 2>/dev/null || true
}

# Function to compress old logs
compress_old_logs() {
    echo "Compressing old log files..."
    
    # Compress .log.1, .log.2, etc. files that aren't already compressed
    find "$LOG_DIR" -name "*.log.[0-9]*" -not -name "*.gz" -type f -exec gzip {} \;
}

# Function to generate log summary
generate_log_summary() {
    local summary_file="$LOG_DIR/log-summary.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "=== SpinWish Log Summary - $timestamp ===" > "$summary_file"
    echo "" >> "$summary_file"
    
    # Disk usage
    echo "Log Directory Disk Usage:" >> "$summary_file"
    du -sh "$LOG_DIR" >> "$summary_file"
    echo "" >> "$summary_file"
    
    # File count and sizes
    echo "Log Files:" >> "$summary_file"
    find "$LOG_DIR" -name "*.log*" -type f -exec ls -lh {} \; | sort >> "$summary_file"
    echo "" >> "$summary_file"
    
    # Recent errors
    echo "Recent Errors (last 24 hours):" >> "$summary_file"
    find "$LOG_DIR" -name "*.log" -type f -mtime -1 -exec grep -l "ERROR" {} \; | while read log_file; do
        echo "From $log_file:" >> "$summary_file"
        grep "ERROR" "$log_file" | tail -10 >> "$summary_file"
        echo "" >> "$summary_file"
    done
    
    # Server restart events
    echo "Recent Server Restarts (last 24 hours):" >> "$summary_file"
    find "$LOG_DIR" -name "*.log" -type f -mtime -1 -exec grep -l "server check started\|Starting SpinWish server" {} \; | while read log_file; do
        echo "From $log_file:" >> "$summary_file"
        grep "server check started\|Starting SpinWish server" "$log_file" | tail -5 >> "$summary_file"
        echo "" >> "$summary_file"
    done
}

# Function to monitor log patterns
monitor_log_patterns() {
    local alert_file="$LOG_DIR/alerts.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check for error patterns in recent logs
    local error_count=$(find "$LOG_DIR" -name "*.log" -type f -mtime -1 -exec grep -c "ERROR" {} \; | awk '{sum+=$1} END {print sum+0}')
    local restart_count=$(find "$LOG_DIR" -name "*.log" -type f -mtime -1 -exec grep -c "Starting SpinWish server" {} \; | awk '{sum+=$1} END {print sum+0}')
    
    # Alert thresholds
    local max_errors=10
    local max_restarts=5
    
    if [ "$error_count" -gt "$max_errors" ]; then
        echo "[$timestamp] ALERT: High error count in last 24h: $error_count (threshold: $max_errors)" >> "$alert_file"
    fi
    
    if [ "$restart_count" -gt "$max_restarts" ]; then
        echo "[$timestamp] ALERT: High restart count in last 24h: $restart_count (threshold: $max_restarts)" >> "$alert_file"
    fi
    
    # Check for disk space
    local disk_usage=$(df "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 80 ]; then
        echo "[$timestamp] ALERT: High disk usage for logs: ${disk_usage}%" >> "$alert_file"
    fi
}

# Function to setup logrotate configuration
setup_logrotate() {
    local logrotate_conf="/etc/logrotate.d/spinwish-cron"
    
    if [ ! -w "/etc/logrotate.d" ]; then
        echo "Warning: Cannot write to /etc/logrotate.d, skipping logrotate setup"
        return 1
    fi
    
    cat > "$logrotate_conf" << EOF
$LOG_DIR/*.log {
    daily
    missingok
    rotate $LOG_RETENTION_COUNT
    compress
    delaycompress
    notifempty
    create 644 $(whoami) $(whoami)
    postrotate
        # Send HUP signal to any processes that might need to reopen log files
        pkill -HUP -f "spinwish-server-manager" 2>/dev/null || true
    endscript
}
EOF
    
    echo "Logrotate configuration created at $logrotate_conf"
}

# Main execution
case "${1:-rotate}" in
    "rotate")
        echo "Checking and rotating logs..."
        check_and_rotate_by_size "$LOG_DIR/server-manager.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        check_and_rotate_by_size "$LOG_DIR/server-output.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        check_and_rotate_by_size "$LOG_DIR/cron-execution.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        ;;
    "cleanup")
        if [ "$ENABLE_LOG_CLEANUP" = "true" ]; then
            cleanup_old_logs "$LOG_CLEANUP_DAYS"
        else
            echo "Log cleanup is disabled in configuration"
        fi
        ;;
    "compress")
        compress_old_logs
        ;;
    "summary")
        generate_log_summary
        echo "Log summary generated at $LOG_DIR/log-summary.txt"
        ;;
    "monitor")
        monitor_log_patterns
        ;;
    "setup-logrotate")
        setup_logrotate
        ;;
    "full-maintenance")
        echo "Performing full log maintenance..."
        check_and_rotate_by_size "$LOG_DIR/server-manager.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        check_and_rotate_by_size "$LOG_DIR/server-output.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        check_and_rotate_by_size "$LOG_DIR/cron-execution.log" "$MAX_LOG_SIZE" "$LOG_RETENTION_COUNT"
        
        if [ "$ENABLE_LOG_CLEANUP" = "true" ]; then
            cleanup_old_logs "$LOG_CLEANUP_DAYS"
        fi
        
        compress_old_logs
        generate_log_summary
        monitor_log_patterns
        echo "Full log maintenance completed"
        ;;
    *)
        echo "Usage: $0 {rotate|cleanup|compress|summary|monitor|setup-logrotate|full-maintenance}"
        echo ""
        echo "Commands:"
        echo "  rotate           - Check and rotate logs based on size"
        echo "  cleanup          - Remove old log files"
        echo "  compress         - Compress old log files"
        echo "  summary          - Generate log summary report"
        echo "  monitor          - Monitor for alert patterns"
        echo "  setup-logrotate  - Setup system logrotate configuration"
        echo "  full-maintenance - Perform all maintenance tasks"
        exit 1
        ;;
esac

exit 0
