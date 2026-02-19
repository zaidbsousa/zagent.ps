#!/bin/bash

# Simple fix: Remove the last duplicate server block for library.zagent.ps
# This finds and removes the duplicate manual redirect block

CONFIG_FILE="/etc/nginx/sites-available/library.zagent.ps"

# Backup
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Find the last occurrence of the duplicate pattern and remove it
# Pattern: "# HTTP to HTTPS redirect" followed by server block with listen 80
# We'll remove the last 5 lines which should be the duplicate block
# But first, let's verify what's at the end

# Count total lines
total_lines=$(wc -l < "$CONFIG_FILE")

# Check last 10 lines to see the duplicate
echo "Last 10 lines of config:"
tail -10 "$CONFIG_FILE"
echo ""

# Remove the last duplicate block (last 5 lines if they match the pattern)
# Actually, let's be smarter - find the line number of the last "# HTTP to HTTPS redirect"
last_redirect_line=$(grep -n "^# HTTP to HTTPS redirect$" "$CONFIG_FILE" | tail -1 | cut -d: -f1)

if [ -n "$last_redirect_line" ]; then
    # Remove from that line to the end of the file (the duplicate block)
    # But wait, we need to keep the Certbot block. Let's check what's there.
    # Actually, the safest is to remove lines starting from the last "# HTTP to HTTPS redirect"
    # that doesn't have the "if ($host" pattern
    
    # Find the last server block that starts after a "# HTTP to HTTPS redirect" comment
    # and doesn't have "if ($host" - that's our duplicate
    
    # Simpler: just remove the last 5 lines (the duplicate manual redirect)
    # But verify first that it's actually a duplicate
    if tail -5 "$CONFIG_FILE" | grep -q "return 301 https://\$server_name\$request_uri"; then
        echo "Removing duplicate block (last 5 lines)..."
        head -n -5 "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    else
        echo "Pattern not found in last 5 lines. Checking manually..."
        exit 1
    fi
else
    echo "No '# HTTP to HTTPS redirect' comment found"
    exit 1
fi

# Test
nginx -t && systemctl reload nginx && echo "✅ Fixed!" || echo "❌ Failed - restoring backup"


