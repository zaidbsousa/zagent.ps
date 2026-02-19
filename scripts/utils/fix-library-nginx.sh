#!/bin/bash

# Fix library.zagent.ps nginx conflict by removing duplicate server block
# Run this on your VPS

CONFIG_FILE="/etc/nginx/sites-available/library.zagent.ps"

echo "🔧 Fixing library.zagent.ps nginx conflict..."
echo ""

# Backup the config
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backed up config to ${CONFIG_FILE}.backup.*"
echo ""

# Remove the duplicate manual redirect block (lines 387-391)
# We'll use sed to remove the duplicate server block
sed -i '/^# HTTP to HTTPS redirect$/,/^}$/d' "$CONFIG_FILE"

# However, we need to be more precise. Let's check what we're removing
echo "Current config has duplicate server blocks. Removing the manual redirect block..."
echo ""

# Use a more precise approach - remove lines 387-391 (the duplicate manual redirect)
# We'll use awk or sed to remove the last duplicate server block
awk '
/^# HTTP to HTTPS redirect$/ && found_redirect { skip=1; next }
/^# HTTP to HTTPS redirect$/ { found_redirect=1; skip=0; next }
skip && /^}$/ { skip=0; next }
!skip { print }
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

# Actually, let's use a simpler approach - remove the last server block that's a duplicate
# We know it starts with "# HTTP to HTTPS redirect" and ends with "}"
# Let's use sed to remove from the second occurrence
sed -i '/^# HTTP to HTTPS redirect$/,/^}$/{ /^# HTTP to HTTPS redirect$/!{ /^}$/!d; }; }' "$CONFIG_FILE"

# Wait, that's getting complex. Let's just manually edit it properly
# The issue is we have:
# 1. Certbot block (lines 374-385) - should keep
# 2. Manual redirect (lines 387-391) - should remove

# Better approach: use sed to remove lines starting from the second "# HTTP to HTTPS redirect" comment
sed -i '/^# HTTP to HTTPS redirect$/,/^}$/{
    /^# HTTP to HTTPS redirect$/{
        :a
        N
        /^}$/!ba
        /^# HTTP to HTTPS redirect$/d
    }
}' "$CONFIG_FILE"

# Actually, the simplest: remove the last occurrence of the duplicate pattern
# Let's count occurrences and remove the last one
grep -n "^# HTTP to HTTPS redirect$" "$CONFIG_FILE" | tail -1 | cut -d: -f1 | while read line_num; do
    if [ -n "$line_num" ]; then
        # Remove from this line to the next closing brace
        sed -i "${line_num},/^}$/d" "$CONFIG_FILE"
    fi
done

echo "✅ Removed duplicate server block"
echo ""

# Test nginx config
echo "🧪 Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuration is valid!"
    echo "🔄 Reloading nginx..."
    systemctl reload nginx || service nginx reload
    echo "✅ Nginx reloaded successfully!"
    echo ""
    echo "✅ Conflict fixed!"
else
    echo ""
    echo "❌ Configuration test failed. Restoring backup..."
    cp "${CONFIG_FILE}.backup."* "$CONFIG_FILE" 2>/dev/null
    echo "⚠️  Please fix manually"
fi

