# SpinWish Server Cron Job Management

This directory contains a comprehensive cron job system for automatically managing your SpinWish Spring Boot server. The system provides automated startup, health monitoring, restart capabilities, and comprehensive logging.

## 🚀 Quick Start

### 1. Installation

Run the installation script to set up cron jobs automatically:

```bash
cd /path/to/spinwish
chmod +x cron-scripts/*.sh
./cron-scripts/install-cron-jobs.sh
```

### 2. Choose Configuration

The installer will prompt you to choose:
- **Production**: Every 3 minutes monitoring + maintenance
- **Development**: Every 10 minutes monitoring + cleanup  
- **Custom**: Choose your own intervals
- **Manual**: Configure manually using provided templates

### 3. Verify Installation

```bash
# Check installed cron jobs
crontab -l

# Test server manager
./cron-scripts/spinwish-server-manager.sh status

# View logs
tail -f logs/cron/cron-execution.log
```

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `spinwish-server-manager.sh` | Main server management script with health checks |
| `log-manager.sh` | Log rotation, cleanup, and monitoring |
| `spinwish-cron.conf` | Configuration file for all settings |
| `crontab-entries.txt` | Template cron entries for manual setup |
| `install-cron-jobs.sh` | Automated installation script |
| `README.md` | This documentation |

## 🔧 Configuration

Edit `spinwish-cron.conf` to customize:

```bash
# Server settings
PROFILE=auto                    # auto, prod, local, dev
SERVER_PORT=8080
JAVA_OPTS="-Xmx1g -Xms512m"

# Health check settings
HEALTH_CHECK_RETRIES=5
HEALTH_CHECK_INTERVAL=10

# Cron schedule toggles
ENABLE_3MIN_CRON=true
ENABLE_5MIN_CRON=false
ENABLE_10MIN_CRON=false

# Logging settings
MAX_LOG_SIZE=50                 # MB
LOG_RETENTION_COUNT=10
LOG_CLEANUP_DAYS=7
```

## 🕐 Cron Schedule Options

### Production (Recommended)
```bash
*/3 * * * *    # Monitor every 3 minutes
30 2 * * *     # Daily maintenance at 2:30 AM
0 3 * * 0      # Weekly restart on Sunday 3:00 AM
@reboot        # Start on system boot
```

### Development
```bash
*/10 * * * *   # Monitor every 10 minutes
0 2 * * *      # Daily cleanup at 2:00 AM
@reboot        # Start on system boot
```

### Custom Options
- Every 3, 5, 10, 15, or 30 minutes
- Business hours only (8 AM - 6 PM, Mon-Fri)
- Weekend monitoring
- Hourly health checks

## 🛠️ Manual Commands

### Server Management
```bash
# Check server status
./cron-scripts/spinwish-server-manager.sh status

# Start server
./cron-scripts/spinwish-server-manager.sh start

# Stop server
./cron-scripts/spinwish-server-manager.sh stop

# Restart server
./cron-scripts/spinwish-server-manager.sh restart

# Health check only
./cron-scripts/spinwish-server-manager.sh health

# Cron-safe start (used by cron jobs)
./cron-scripts/spinwish-server-manager.sh cron
```

### Log Management
```bash
# Rotate logs
./cron-scripts/log-manager.sh rotate

# Cleanup old logs
./cron-scripts/log-manager.sh cleanup

# Compress old logs
./cron-scripts/log-manager.sh compress

# Generate summary report
./cron-scripts/log-manager.sh summary

# Monitor for alerts
./cron-scripts/log-manager.sh monitor

# Full maintenance
./cron-scripts/log-manager.sh full-maintenance
```

## 📊 Monitoring & Logs

### Log Locations
```
logs/cron/
├── cron-execution.log      # Main cron job output
├── server-manager.log      # Server management events
├── server-output.log       # Server startup output
├── maintenance.log         # Daily maintenance tasks
├── health-check.log        # Health check results
├── alerts.log             # System alerts
└── log-summary.txt        # Daily summary report
```

### Health Checks

The system performs comprehensive health checks:
- Process existence verification
- HTTP endpoint health check (`/actuator/health`)
- Configurable retry logic
- Automatic restart on failure

### Alerting

Monitor these patterns in logs:
- High error counts (>10 errors/24h)
- Frequent restarts (>5 restarts/24h)
- High disk usage (>80%)
- Failed health checks

## 🔒 Security & Permissions

### File Permissions
```bash
# Scripts are executable
chmod +x cron-scripts/*.sh

# Config file is readable
chmod 644 cron-scripts/spinwish-cron.conf

# Log directory is writable
chmod 755 logs/cron/
```

### User Context
- Runs as the user who installed the cron jobs
- Does not require root privileges
- Uses existing project permissions

## 🐛 Troubleshooting

### Cron Jobs Not Running

1. **Check cron service:**
   ```bash
   sudo systemctl status cron
   sudo systemctl start cron
   ```

2. **Verify crontab:**
   ```bash
   crontab -l
   ```

3. **Check system cron logs:**
   ```bash
   sudo tail -f /var/log/cron
   # or
   sudo journalctl -u cron -f
   ```

### Server Not Starting

1. **Test manually:**
   ```bash
   ./cron-scripts/spinwish-server-manager.sh start
   ```

2. **Check logs:**
   ```bash
   tail -f logs/cron/server-manager.log
   tail -f logs/cron/server-output.log
   ```

3. **Verify project structure:**
   ```bash
   ls -la smart_start.sh start.sh backend/
   ```

### Health Checks Failing

1. **Test health endpoint:**
   ```bash
   curl -s http://localhost:8080/actuator/health
   ```

2. **Check server logs:**
   ```bash
   tail -f backend/logs/spring.log
   ```

3. **Verify port configuration:**
   ```bash
   netstat -tlnp | grep 8080
   ```

## 📈 Performance Tuning

### Monitoring Frequency
- **High-traffic production**: Every 3 minutes
- **Standard production**: Every 5 minutes
- **Development**: Every 10-15 minutes
- **Testing**: Every 30 minutes

### Resource Usage
- Each check uses minimal CPU/memory
- Log rotation prevents disk space issues
- Health checks timeout after 30 seconds

## 🔄 Maintenance

### Daily Tasks (Automated)
- Log rotation based on size
- Old log cleanup
- Health pattern monitoring
- Summary report generation

### Weekly Tasks (Optional)
- Server restart for memory cleanup
- Log compression
- System health review

### Monthly Tasks
- Configuration review
- Performance analysis
- Log archive cleanup

## 🆘 Emergency Procedures

### Stop All Cron Jobs
```bash
# Temporarily disable
crontab -r

# Or comment out SpinWish entries
crontab -e
```

### Force Server Stop
```bash
# Graceful stop
./cron-scripts/spinwish-server-manager.sh stop

# Force kill if needed
pkill -f "spring-boot.*backend"
```

### Reset Configuration
```bash
# Restore from backup
cp backups/cron/crontab_backup_*.txt current_crontab.txt
crontab current_crontab.txt

# Or reinstall
./cron-scripts/install-cron-jobs.sh
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review log files in `logs/cron/`
3. Test scripts manually before debugging cron
4. Verify system requirements and permissions

---

**Note**: This system is designed for Linux/Unix environments with standard cron implementations. Adjust paths and commands as needed for your specific setup.
