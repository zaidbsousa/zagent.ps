#!/bin/bash

# Fix library.zagent.ps nginx conflict by removing duplicate server blocks
# This script removes all duplicate HTTP redirect blocks and keeps only the Certbot-managed one

CONFIG_FILE="/etc/nginx/sites-available/library.zagent.ps"

echo "🔧 Fixing library.zagent.ps nginx conflict..."
echo ""

# Backup the config
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backed up config"
echo ""

# Remove all duplicate manual redirect blocks
# Keep only the Certbot-managed block (the one with "if ($host" statement)
# Remove any server block that:
# - Has "listen 80"
# - Has "return 301 https://\$server_name\$request_uri" (manual redirect pattern)
# - Does NOT have "if (\$host" (Certbot block identifier)
# - Does NOT have "managed by Certbot"

# Use awk to process the file and remove duplicate blocks
awk '
BEGIN { in_block = 0; block = "" }
/^server \{/ {
    if (in_block) {
        print block
    }
    in_block = 1
    block = $0 "\n"
    has_if = 0
    has_listen_80 = 0
    has_manual_redirect = 0
    has_certbot = 0
    next
}
in_block {
    block = block $0 "\n"
    if (/if.*\$host.*library\.zagent\.ps/) has_if = 1
    if (/listen 80/) has_listen_80 = 1
    if (/return 301 https:\/\/\$server_name\$request_uri/) has_manual_redirect = 1
    if (/managed by Certbot/) has_certbot = 1
}
/^}$/ && in_block {
    in_block = 0
    if (has_listen_80 && has_manual_redirect && !has_if && !has_certbot) {
        block = ""
        next
    } else {
        printf "%s", block
    }
    block = ""
    next
}
!in_block {
    print
}
END {
    if (in_block) {
        printf "%s", block
    }
}
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo "✅ Removed duplicate server blocks"
echo ""

# Test nginx config
echo "🧪 Testing nginx configuration..."
nginx -t 2>&1 | tee /tmp/nginx_test_output.txt

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    # Check if conflict is resolved
    if grep -q "conflicting server name" /tmp/nginx_test_output.txt; then
        echo ""
        echo "⚠️  Warning: Conflict still exists. Showing current 'listen 80' blocks:"
        echo ""
        grep -n -A 3 "listen 80" "$CONFIG_FILE" | grep -v "^[0-9]*:#"
        echo ""
        echo "Please review the config manually."
    else
        echo ""
        echo "✅ Configuration is valid and conflict resolved!"
        echo "🔄 Reloading nginx..."
        systemctl reload nginx || service nginx reload
        echo "✅ Nginx reloaded successfully!"
        echo ""
        echo "✅ Conflict fixed!"
    fi
    rm -f /tmp/nginx_test_output.txt
else
    echo ""
    echo "❌ Configuration test failed. Restoring backup..."
    cp "${CONFIG_FILE}.backup."* "$CONFIG_FILE" 2>/dev/null
    echo "⚠️  Please fix manually"
    rm -f /tmp/nginx_test_output.txt
    exit 1
fi

