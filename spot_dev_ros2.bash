#!/bin/bash
# This script sets up a tmux development environment for the spot_ros2 project.
# Usage: ./spot_dev_ros2.bash [robot_name]
# Example: ./spot_dev_ros2.bash tusker

if [ -z "$1" ]; then
    echo "Usage: ./spot_dev_ros2.bash [robot_name]"
    echo "Please provide the name of the spot robot (e.g., tusker)."
    exit 1
fi

ROBOT_NAME=$1

# Define the ROS2 commands to be used
LAUNCH_DRIVER_CMD="ros2 launch spot_driver spot_driver.launch.py controllable:=True spot_name:=${ROBOT_NAME}"
# The file_server package is not in this project. This is a placeholder.
LAUNCH_SERVER_CMD="echo 'launchserver equivalent not found in this project'"
# The following are example commands. You may need to adjust the topics.
ALL_CAMS_CMD="ros2 topic echo /camera/frontleft/image"
ALL_DEPTH_CMD="ros2 topic echo /depth/image" # Example topic, adjust as needed
ALL_EXT_CMD="ros2 topic echo /tf"

tmux new-session  \;
        # Pane 0: Main driver
        send-keys "source setup.bash ${ROBOT_NAME}" Enter \;
        split-window -v \;
        # Pane 1: Camera data
        send-keys "source setup.bash ${ROBOT_NAME}" Enter \;
        split-window -h \;
        # Pane 2: Depth data
        send-keys "source setup.bash ${ROBOT_NAME}" Enter \;
        split-window -h \;
        # Pane 3: TF data
        send-keys "source setup.bash ${ROBOT_NAME}" Enter \;
        split-window -t %0 -h \;
        # Pane 4: Server
        send-keys "source setup.bash ${ROBOT_NAME}" Enter \;
        # Resize panes to a reasonable layout
        resize-pane -t %1 -L 26 \;
        resize-pane -t %2 -L 12 \;
        # Synchronize panes to wait for driver to start
        wait-for -L lock1\;\
                send-keys -t %0 'sleep 3' Enter 'tmux wait-for -U lock1' Enter C-m \;
                wait-for -L lock1 \;
        # Launch the main driver
        send-keys -t %0 "${LAUNCH_DRIVER_CMD}" Enter \;
        # Launch the server
        send-keys -t %4 "${LAUNCH_SERVER_CMD}" Enter \;
        # Wait for a bit longer before starting data viewers
        wait-for -L lock2\;\
                send-keys -t %1 'sleep 8' Enter 'tmux wait-for -U lock2' Enter C-m \;
                wait-for -L lock2 \;
        # Start viewing data
        send-keys -t %1 "${ALL_CAMS_CMD}" Enter \;
        send-keys -t %2 "${ALL_DEPTH_CMD}" Enter \;
        send-keys -t %3 "${ALL_EXT_CMD}" Enter \;
        # Enable mouse support for convenience
        set -g mouse on
