#!/bin/bash

# Path to the log file
LOG_FILE="/etc/nginx/nginx.log" // use path of Nginx or Apache or any other 

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "Log file not found: $LOG_FILE"
  exit 1
fi

# Check if log file is readable
if [ ! -r "$LOG_FILE" ]; then
  echo "Log file is not readable: $LOG_FILE"
  exit 1
fi

# Number of 404 errors
ERROR_404_COUNT=$(grep " 404 " "$LOG_FILE" | wc -l)

# Most requested pages
MOST_REQUESTED_PAGES=$(awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)

# IP addresses with the most requests
MOST_REQUESTED_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)

# Print the summarized report
echo "Summary Report"
echo "--------------"
echo "Number of 404 errors: $ERROR_404_COUNT"
echo ""
echo "Most Requested Pages:"
if [ -n "$MOST_REQUESTED_PAGES" ]; then
  echo "$MOST_REQUESTED_PAGES"
else
  echo "No data available for most requested pages."
fi
echo ""
echo "IP Addresses with Most Requests:"
if [ -n "$MOST_REQUESTED_IPS" ]; then
  echo "$MOST_REQUESTED_IPS"
else
  echo "No data available for IP addresses."
fi
