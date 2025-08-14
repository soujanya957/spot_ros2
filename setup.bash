#!/bin/bash

# Source this script to set up the Spot ROS 2 environment
# Usage: source setup.bash [robot_name]
#
# Example: source setup.bash tusker

# --- Change to script's directory ---
# This script is intended to be sourced from the root of the workspace.
cd "$(dirname "${BASH_SOURCE[0]}")"

# --- Robot Configuration ---
# Add your Spot robots here
# You can add more robots by following the same pattern.
if [ -z "$1" ]; then
    echo "Usage: source setup.bash [robot_name]"
    echo "Available robots: gouger, tusker, rooter, snouter"
    return 1
fi

ROBOT_NAME=$1
echo "Setting up environment for: ${ROBOT_NAME}"

if [ "${ROBOT_NAME}" = "gouger" ]; then
    export SPOT_IP="128.148.140.21"
elif [ "${ROBOT_NAME}" = "tusker" ]; then
    export SPOT_IP="128.148.140.22"
elif [ "${ROBOT_NAME}" = "rooter" ]; then
    export SPOT_IP="138.16.161.23"
elif [ "${ROBOT_NAME}" = "snouter" ]; then
    export SPOT_IP="128.148.140.20"
else
    echo "Unknown robot: ${ROBOT_NAME}"
    return 1
fi

echo "SPOT_IP set to: ${SPOT_IP}"

# --- Source Workspace ---
if [ -f "install/setup.bash" ]; then
    echo "Sourcing ROS2 workspace..."
    source "install/setup.bash"
else
    echo "Workspace not built yet. Please run 'colcon build' first."
    return 1
fi

# --- Connection Check ---
echo "Pinging Spot at ${SPOT_IP}..."
if ping -c 1 ${SPOT_IP} &> /dev/null; then
    echo "Successfully connected to Spot at ${SPOT_IP}."
else
    echo "Warning: Could not ping Spot at ${SPOT_IP}."
fi

# --- Environment Variables for Authentication ---
# The driver will automatically use these environment variables if they are set.
if [ -z "$BOSDYN_CLIENT_USERNAME" ]; then
    echo "Reminder: Set the BOSDYN_CLIENT_USERNAME environment variable."
fi
if [ -z "$BOSDYN_CLIENT_PASSWORD" ]; then
    echo "Reminder: Set the BOSDYN_CLIENT_PASSWORD environment variable."
fi

echo "Setup complete."
