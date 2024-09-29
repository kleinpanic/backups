#!/usr/bin/env bash

# Set up environment if needed
export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

# Path to the battery monitor binary
BINARY_PATH="/usr/local/bin/battery_monitor"

# Log file
LOG_FILE="/tmp/battery_monitor.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Log starting message and environment variables
echo "Starting battery monitor script" >> "$LOG_FILE"
echo "DISPLAY=$DISPLAY" >> "$LOG_FILE"
echo "XAUTHORITY=$XAUTHORITY" >> "$LOG_FILE"

# Check if binary exists and is executable
if [ ! -x "$BINARY_PATH" ]; then
    echo "Binary not found or not executable: $BINARY_PATH" >> "$LOG_FILE"
    exit 1
fi

# Start the battery monitor and redirect output to log file
exec "$BINARY_PATH" >> "$LOG_FILE" 2>&1

