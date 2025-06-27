# Jamf Set Computer Name Script

This Bash script generates a unique computer name for a Mac and sets it via [Jamf Pro]

-----

## Overview

The script constructs a computer name using:
- The first initial and last name of the currently logged-in user
- The Mac’s serial number

The format is:
<first initial><last name>-<serial number>

Example: `jsmith-C02ZZZZZZZ`

This name is then applied using the `jamf setComputerName` command.

-----

## How It Works

1. Detects the currently logged-in user.
2. Retrieves their full name from the system directory.
3. Converts the name to lowercase, extracts the first initial and last name.
4. Retrieves the device's serial number.
5. Combines them into a computer name.
6. Applies the name with Jamf.
