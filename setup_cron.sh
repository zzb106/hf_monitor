#!/bin/bash

# Get the absolute path of the current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_PATH="cd $SCRIPT_DIR && ./update_and_download.sh"

# Cron schedule: Every hour (at minute 7 to avoid top-of-the-hour spikes)
CRON_SCHEDULE="7 * * * *"
CRON_JOB="$CRON_SCHEDULE $SCRIPT_PATH >> $SCRIPT_DIR/cron_log.log 2>&1"

# Check if the job already exists in crontab
(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH")

if [ $? -eq 0 ]; then
    echo "Cron job already exists. Skipping setup."
else
    echo "Setting up cron job to run every hour..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job successfully installed."
fi
