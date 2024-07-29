#!/bin/bash

# Variables
LOCAL_DIR="/root/wisecow"
BUCKET_NAME="wisecow-backup"
S3_DIR="backup-directory"
ARCHIVE_NAME="wisecow_backup.tar.gz"
LOG_FILE="backup_log.txt"

# Function to log messages
log_message() {
    local MESSAGE=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $MESSAGE" >> $LOG_FILE
}

# Start backup
log_message "Starting backup process"

START_TIME=$(date +%s)

# Create a tarball of the directory
tar -czvf $ARCHIVE_NAME -C $LOCAL_DIR .

# Check if tar command was successful
if [ $? -eq 0 ]; then
    log_message "Archive created successfully"
else
    log_message "Failed to create archive"
    exit 1
fi

# Upload the tarball to S3
aws s3 cp $ARCHIVE_NAME s3://$BUCKET_NAME/$S3_DIR/

# Check if aws s3 cp was successful
if [ $? -eq 0 ]; then
    log_message "Backup uploaded successfully"
else
    log_message "Backup upload failed"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

log_message "Backup process completed in $(($DURATION / 60)) minutes and $(($DURATION % 60)) seconds"

# Clean up the archive
rm -f $ARCHIVE_NAME
log_message "Temporary archive file removed"

# Display log file contents
cat $LOG_FILE
