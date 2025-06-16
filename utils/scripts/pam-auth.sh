#!/bin/bash

# PAM Authentication script for NekroShell lockscreen
# This script validates the user's password using PAM without relying on sudo

set -euo pipefail

USERNAME="${USER:-$(whoami)}"
PASSWORD=""

# Read password from stdin
read -r PASSWORD

if [ -z "$PASSWORD" ]; then
    echo "AUTH_FAILED"
    exit 1
fi

# Method 1: Try pamtester if available (most secure and reliable)
if command -v pamtester >/dev/null 2>&1; then
    if echo "$PASSWORD" | pamtester login "$USERNAME" authenticate >/dev/null 2>&1; then
        echo "AUTH_SUCCESS"
        exit 0
    fi
fi

# Method 2: Use python3 with PAM module if available
if command -v python3 >/dev/null 2>&1; then
    PYTHON_AUTH_RESULT=$(python3 -c "
import sys
import os
try:
    import pam
    p = pam.pam()
    username = '$USERNAME'
    password = '$PASSWORD'
    if p.authenticate(username, password):
        print('SUCCESS')
    else:
        print('FAILED')
except ImportError:
    print('FAILED')
except Exception:
    print('FAILED')
" 2>/dev/null)
    
    if [ "$PYTHON_AUTH_RESULT" = "SUCCESS" ]; then
        echo "AUTH_SUCCESS"
        exit 0
    fi
fi

# Method 3: Use su command (more secure than sudo for password validation)
# Create a temporary script that just runs 'true'
TEMP_SCRIPT=$(mktemp)
echo "#!/bin/bash" > "$TEMP_SCRIPT"
echo "true" >> "$TEMP_SCRIPT"
chmod +x "$TEMP_SCRIPT"

# Use su to validate password
if echo "$PASSWORD" | su "$USERNAME" -c "$TEMP_SCRIPT" >/dev/null 2>&1; then
    rm -f "$TEMP_SCRIPT"
    echo "AUTH_SUCCESS"
    exit 0
fi

# Clean up
rm -f "$TEMP_SCRIPT"

echo "AUTH_FAILED"
exit 1
