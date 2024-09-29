#!/usr/bin/env bash

# Function to check if a command exists
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Installing..."
        sudo apt-get install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Step 1: Finding the current working directory and script location
SCRIPT_DIR=$(pwd)
BASH_SCRIPT="$SCRIPT_DIR/battery_daemon.sh"
SRC_SCRIPT="$SCRIPT_DIR/battery_monitor"

# Check if battery_daemon.sh exists
if [[ -f "$BASH_SCRIPT" ]]; then
    echo "Found battery_daemon.sh. Moving to /usr/local/bin."
    sudo cp "$BASH_SCRIPT" /usr/local/bin/battery_daemon.sh
    sudo cp "$SRC_SCRIPT" /usr/local/bin/battery_monitor
    sudo chmod +x /usr/local/bin/battery_daemon
    sudo chmod +x /usr/local/bin/battery_daemon.sh
else
    echo "battery_daemon.sh not found in the current directory!"
    exit 1
fi

# Step 2: Check for dependencies and install if not present
dependencies=("gcc" "make" "brightnessctl")

for dep in "${dependencies[@]}"; do
    check_dependency "$dep"
done

# Step 3: Copy battery_monitor.service to systemd folder
SYSTEMD_SERVICE="$SCRIPT_DIR/battery_monitor.service"
if [[ -f "$SYSTEMD_SERVICE" ]]; then
    echo "Found battery_monitor.service. Copying to /etc/systemd/system/"
    sudo cp "$SYSTEMD_SERVICE" /etc/systemd/system/
else
    echo "battery_monitor.service not found in the current directory!"
    exit 1
fi

# Step 4: Reload the systemd daemon, enable and restart the service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling battery_monitor.service..."
sudo systemctl enable battery_monitor.service

echo "Restarting battery_monitor.service..."
sudo systemctl restart battery_monitor.service

# Check if the service was successfully started
if systemctl is-active --quiet battery_monitor.service; then
    echo "Service started successfully!"
else
    echo "Failed to start the service."
    exit 1
fi
