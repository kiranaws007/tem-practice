#!/bin/bash

# Variables
URL="http://54.242.98.61"  # Include prover url and protocol and optionally port if neede
LOG_FILE="app_health.log"
STATUS_UP="200"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

# Function to check application health
check_app_health() {
    HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $URL)

    if [ $? -ne 0 ]; then
        log_message "Failed to perform health check on $URL"
        return 1
    fi

    if [ "$HTTP_STATUS" == "$STATUS_UP" ]; then
        log_message "Application is up. HTTP Status: $HTTP_STATUS"
    else
        log_message "Application is down. HTTP Status: $HTTP_STATUS"
    fi
}

# Check if the log file is writable
if [ ! -w "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE is not writable. Exiting."
    exit 1
fi

# Run the application health check
log_message "Starting application health check"
check_app_health
log_message "Application health check completed"

# Display the log file
cat $LOG_FILE
