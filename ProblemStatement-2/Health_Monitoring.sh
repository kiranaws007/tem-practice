# HEALTH MONITORING REMOTE SERVER
#!/bin/bash

# Variables
REMOTE_USER="ubuntu"
REMOTE_HOST="ec2-54-242-98-61.compute-1.amazonaws.com"
REMOTE_LOG_FILE="remote_system_health.log"
LOCAL_LOG_FILE="remote_health_monitor.log"
PEM_FILE="/c/Users/kiran/Downloads/cowsay.pem"  # Use the correct path to your .pem file or give permission to remote server better Skip this beacuse of security threat

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOCAL_LOG_FILE
}

# Function to run checks on the remote server
run_remote_checks() {
    ssh -i $PEM_FILE $REMOTE_USER@$REMOTE_HOST "
    CPU_USAGE=\$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - \$1}')
    MEM_USAGE=\$(free | grep Mem | awk '{print \$3/\$2 * 100.0}')
    DISK_USAGE=\$(df / | grep / | awk '{print \$5}' | sed 's/%//g')
    PROCESS_COUNT=\$(ps -e | wc -l)
    echo \$(date +\"%Y-%m-%d %H:%M:%S\") - Starting remote system health check >> $REMOTE_LOG_FILE
    if (( \$(echo \"\$CPU_USAGE > 80\" | bc -l) )); then
        echo \$(date +\"%Y-%m-%d %H:%M:%S\") - High CPU usage: \$CPU_USAGE% >> $REMOTE_LOG_FILE
    fi
    if (( \$(echo \"\$MEM_USAGE > 80\" | bc -l) )); then
        echo \$(date +\"%Y-%m-%d %H:%M:%S\") - High Memory usage: \$MEM_USAGE% >> $REMOTE_LOG_FILE
    fi
    if (( \$DISK_USAGE > 80 )); then
        echo \$(date +\"%Y-%m-%d %H:%M:%S\") - High Disk usage: \$DISK_USAGE% >> $REMOTE_LOG_FILE
    fi
    if (( \$PROCESS_COUNT > 200 )); then
        echo \$(date +\"%Y-%m-%d %H:%M:%S\") - High number of processes: \$PROCESS_COUNT >> $REMOTE_LOG_FILE
    fi
    echo \$(date +\"%Y-%m-%d %H:%M:%S\") - Remote system health check completed >> $REMOTE_LOG_FILE
    "
}

# Run remote checks and fetch the log file
run_remote_checks

# Check if the remote command was successful
if [ $? -eq 0 ]; then
    scp -i $PEM_FILE $REMOTE_USER@$REMOTE_HOST:$REMOTE_LOG_FILE $LOCAL_LOG_FILE
    if [ $? -eq 0 ]; then
        log_message "Log file successfully transferred from remote server."
        # Display the log file
        cat $LOCAL_LOG_FILE
    else
        log_message "Failed to transfer log file from remote server."
    fi
else
    log_message "Failed to execute remote health check."
fi
