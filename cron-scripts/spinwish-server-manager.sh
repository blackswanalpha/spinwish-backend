#!/bin/bash

# SpinWish Server Management Script for Cron Jobs
# This script provides comprehensive server management with health checks,
# process detection, and proper error handling for automated cron execution.

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/spinwish-cron.conf"
LOG_DIR="$PROJECT_ROOT/logs/cron"
PID_FILE="$PROJECT_ROOT/spinwish-server.pid"
HEALTH_CHECK_URL="http://localhost:8080/actuator/health"
HEALTH_CHECK_TIMEOUT=30
MAX_START_ATTEMPTS=3
START_TIMEOUT=120

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Default configuration values
SERVER_PORT=${SERVER_PORT:-8080}
PROFILE=${PROFILE:-auto}
JAVA_OPTS=${JAVA_OPTS:-"-Xmx1g -Xms512m"}
HEALTH_CHECK_RETRIES=${HEALTH_CHECK_RETRIES:-5}
HEALTH_CHECK_INTERVAL=${HEALTH_CHECK_INTERVAL:-10}

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/server-manager.log"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { log "DEBUG" "$@"; }

# Function to get server PID
get_server_pid() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "$pid"
            return 0
        else
            # PID file exists but process is dead, clean it up
            rm -f "$PID_FILE"
        fi
    fi
    
    # Try to find process by pattern
    local pid=$(pgrep -f "spring-boot.*backend.*jar" | head -1)
    if [ -n "$pid" ]; then
        echo "$pid" > "$PID_FILE"
        echo "$pid"
        return 0
    fi
    
    return 1
}

# Function to check if server is running
is_server_running() {
    local pid=$(get_server_pid)
    [ -n "$pid" ] && return 0 || return 1
}

# Function to perform health check
health_check() {
    local retries=${1:-$HEALTH_CHECK_RETRIES}
    local interval=${2:-$HEALTH_CHECK_INTERVAL}
    
    log_info "Performing health check (retries: $retries, interval: ${interval}s)"
    
    for ((i=1; i<=retries; i++)); do
        if curl -s --max-time "$HEALTH_CHECK_TIMEOUT" "$HEALTH_CHECK_URL" >/dev/null 2>&1; then
            log_info "Health check passed on attempt $i"
            return 0
        fi
        
        if [ $i -lt $retries ]; then
            log_debug "Health check failed on attempt $i, retrying in ${interval}s..."
            sleep "$interval"
        fi
    done
    
    log_error "Health check failed after $retries attempts"
    return 1
}

# Function to stop the server
stop_server() {
    log_info "Stopping SpinWish server..."
    
    local pid=$(get_server_pid)
    if [ -z "$pid" ]; then
        log_info "Server is not running"
        return 0
    fi
    
    log_info "Sending TERM signal to process $pid"
    kill -TERM "$pid" 2>/dev/null
    
    # Wait for graceful shutdown
    local timeout=30
    for ((i=0; i<timeout; i++)); do
        if ! kill -0 "$pid" 2>/dev/null; then
            log_info "Server stopped gracefully"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
    done
    
    # Force kill if still running
    log_warn "Server did not stop gracefully, forcing shutdown"
    kill -KILL "$pid" 2>/dev/null
    rm -f "$PID_FILE"
    
    # Verify it's stopped
    if kill -0 "$pid" 2>/dev/null; then
        log_error "Failed to stop server process $pid"
        return 1
    else
        log_info "Server forcefully stopped"
        return 0
    fi
}

# Function to start the server
start_server() {
    log_info "Starting SpinWish server with profile: $PROFILE"
    
    if is_server_running; then
        log_warn "Server is already running (PID: $(get_server_pid))"
        return 0
    fi
    
    cd "$PROJECT_ROOT" || {
        log_error "Failed to change to project directory: $PROJECT_ROOT"
        return 1
    }
    
    # Choose startup method based on profile
    local start_command
    case "$PROFILE" in
        "auto")
            start_command="./smart_start.sh"
            ;;
        "prod"|"local"|"dev")
            start_command="./start.sh $PROFILE"
            ;;
        *)
            log_error "Unknown profile: $PROFILE"
            return 1
            ;;
    esac
    
    log_info "Executing: $start_command"
    
    # Start server in background and capture PID
    nohup $start_command > "$LOG_DIR/server-output.log" 2>&1 &
    local start_pid=$!
    
    # Wait for the actual Java process to start
    local java_pid=""
    local attempts=0
    while [ $attempts -lt $MAX_START_ATTEMPTS ] && [ -z "$java_pid" ]; do
        sleep 5
        java_pid=$(pgrep -f "spring-boot.*backend.*jar" | head -1)
        attempts=$((attempts + 1))
        log_debug "Waiting for Java process to start (attempt $attempts)..."
    done
    
    if [ -n "$java_pid" ]; then
        echo "$java_pid" > "$PID_FILE"
        log_info "Server started with PID: $java_pid"
        
        # Wait for server to be ready
        log_info "Waiting for server to be ready..."
        if health_check; then
            log_info "Server is healthy and ready"
            return 0
        else
            log_error "Server started but health check failed"
            return 1
        fi
    else
        log_error "Failed to start server - no Java process found"
        return 1
    fi
}

# Function to restart the server
restart_server() {
    log_info "Restarting SpinWish server..."
    
    if is_server_running; then
        stop_server || {
            log_error "Failed to stop server during restart"
            return 1
        }
        sleep 5
    fi
    
    start_server
}

# Function to get server status
server_status() {
    if is_server_running; then
        local pid=$(get_server_pid)
        log_info "Server is running (PID: $pid)"
        
        if health_check 1 5; then
            log_info "Server is healthy"
            return 0
        else
            log_warn "Server is running but not healthy"
            return 2
        fi
    else
        log_info "Server is not running"
        return 1
    fi
}

# Function for cron-safe execution
cron_safe_start() {
    log_info "=== Cron-triggered server check started ==="
    
    # Check if server is running and healthy
    if server_status; then
        log_info "Server is running and healthy, no action needed"
        return 0
    fi
    
    local status_code=$?
    if [ $status_code -eq 2 ]; then
        log_warn "Server is running but unhealthy, restarting..."
        restart_server
    else
        log_info "Server is not running, starting..."
        start_server
    fi
    
    log_info "=== Cron-triggered server check completed ==="
}

# Main execution
case "${1:-status}" in
    "start")
        start_server
        ;;
    "stop")
        stop_server
        ;;
    "restart")
        restart_server
        ;;
    "status")
        server_status
        ;;
    "health")
        health_check
        ;;
    "cron")
        cron_safe_start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|health|cron}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the server"
        echo "  stop    - Stop the server"
        echo "  restart - Restart the server"
        echo "  status  - Check server status"
        echo "  health  - Perform health check"
        echo "  cron    - Cron-safe start (checks if needed)"
        exit 1
        ;;
esac

exit $?
