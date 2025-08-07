#!/bin/bash

# Install systemd service for *arr stack

set -e

SERVICE_FILE="servarr.service"
SYSTEMD_PATH="/etc/systemd/system/"

echo "Installing *arr Stack systemd service..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo ./install-service.sh)"
    exit 1
fi

# Copy service file
cp "$SERVICE_FILE" "$SYSTEMD_PATH"
echo "✓ Service file copied to $SYSTEMD_PATH"

# Reload systemd
systemctl daemon-reload
echo "✓ Systemd daemon reloaded"

# Enable service
systemctl enable servarr.service
echo "✓ Service enabled for auto-start"

echo ""
echo "Service commands:"
echo "  sudo systemctl start servarr     # Start services"
echo "  sudo systemctl stop servarr      # Stop services"
echo "  sudo systemctl status servarr    # Check status"
echo "  sudo systemctl disable servarr   # Disable auto-start"
echo ""
echo "Service installed successfully!"
