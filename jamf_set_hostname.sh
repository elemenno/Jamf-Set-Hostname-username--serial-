#!/bin/bash

# Get the currently logged-in username (console user)
USERNAME=$(stat -f%Su /dev/console)

# Get the full name of the user
FULL_NAME=$(dscl . -read /Users/"$USERNAME" RealName | tail -1)

# Convert full name to lowercase
FULL_NAME_LOWER=$(echo "$FULL_NAME" | tr '[:upper:]' '[:lower:]')

# Extract first initial and last name
FIRST_INITIAL=$(echo "$FULL_NAME_LOWER" | awk '{print substr($1,1,1)}')
LAST_NAME=$(echo "$FULL_NAME_LOWER" | awk '{print $NF}')

# Get the Mac's serial number
SERIAL_NUMBER=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')

# Combine into one output variable
COMPNAME="${FIRST_INITIAL}${LAST_NAME}-${SERIAL_NUMBER}"

# Use the output (e.g., print to terminal)
#echo "$OUTPUT"


# Set Computer Name
sudo jamf setComputerName -name "$COMPNAME"