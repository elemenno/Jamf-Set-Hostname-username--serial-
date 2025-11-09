#!/bin/bash

# Get the currently logged-in username (console user)
USERNAME=$(stat -f%Su /dev/console 2>/dev/null || echo "")

# Get the user's full name (prefer id -F; fallback to dscl). Strip CRs and trim.
FULL_NAME=$(
  (id -F "$USERNAME" 2>/dev/null || dscl . -read "/Users/$USERNAME" RealName 2>/dev/null | tail -1) \
  | tr -d '\r' | awk '{$1=$1; print}'
)

# If empty for any reason, fall back to account name
if [[ -z "$FULL_NAME" ]]; then
  FULL_NAME="$USERNAME"
fi

# Lowercase for hostname
FULL_NAME_LOWER=$(printf '%s' "$FULL_NAME" | tr '[:upper:]' '[:lower:]')

# Split into words
read -r -a NAME_PARTS <<< "$FULL_NAME_LOWER"
WORDS=${#NAME_PARTS[@]}

FIRST_NAME=""; LAST_NAME=""
if [[ $WORDS -ge 1 ]]; then FIRST_NAME="${NAME_PARTS[0]}"; fi
if [[ $WORDS -ge 2 ]]; then LAST_NAME="${NAME_PARTS[$((WORDS-1))]}"; fi

# Sanitize: letters/numbers only
FIRST_NAME=$(echo "$FIRST_NAME" | tr -cd 'a-z0-9')
LAST_NAME=$(echo "$LAST_NAME" | tr -cd 'a-z0-9')

# Get serial quickly (no system_profiler delay)
SERIAL_NUMBER=$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | awk -F\" '/IOPlatformSerialNumber/{print $4}')
SERIAL_NUMBER=${SERIAL_NUMBER:-unknownserial}

# Build base name: full first name if only one word; otherwise first initial + last name
if [[ -n "$LAST_NAME" ]]; then
  BASE="${FIRST_NAME:0:1}${LAST_NAME}"
else
  BASE="${FIRST_NAME}"
fi
BASE=${BASE:-mac}

COMPNAME="${BASE}-${SERIAL_NUMBER}"
# Normalize hyphens
COMPNAME=$(echo "$COMPNAME" | sed -E 's/-+/-/g; s/^-+//; s/-+$//')

# Apply names
scutil --set HostName "$COMPNAME"
scutil --set LocalHostName "$COMPNAME"
scutil --set ComputerName "$COMPNAME"

# NetBIOS must be <=15 chars and alphanumeric
NETBIOS=$(echo "$COMPNAME" | tr -cd '[:alnum:]' | cut -c1-15)
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName "$NETBIOS"

# Flush directory cache
dscacheutil -flushcache || true

# Update Jamf inventory if available
if command -v jamf >/dev/null 2>&1; then
  jamf recon
fi

exit 0
