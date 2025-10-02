#!/bin/bash

# audit.sh - Append every hook payload to /tmp/agent-audit.log for debugging

json_input=$(cat)

# Timestamp entries so the log is more readable
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$(dirname /tmp/agent-audit.log)"

echo "[$timestamp] $json_input" >> /tmp/agent-audit.log

exit 0
