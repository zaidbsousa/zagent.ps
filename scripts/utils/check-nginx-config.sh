#!/bin/bash

# Script to check nginx configuration on the server
# Usage: ./check-nginx-config.sh YOUR_VPS_IP [username]

VPS_IP=${1:-"72.60.188.157"}
USERNAME=${2:-"root"}

echo "🔍 Checking nginx configuration on server..."

ssh $USERNAME@$VPS_IP << 'EOF'
    echo "=== Checking if nginx config exists ==="
    ls -la /etc/nginx/sites-available/test.zagent.ps 2>/dev/null || echo "❌ Config file not found"
    ls -la /etc/nginx/sites-enabled/test.zagent.ps 2>/dev/null || echo "❌ Symlink not found"
    
    echo ""
    echo "=== Nginx config content ==="
    if [ -f /etc/nginx/sites-available/test.zagent.ps ]; then
        cat /etc/nginx/sites-available/test.zagent.ps
    else
        echo "Config file doesn't exist"
    fi
    
    echo ""
    echo "=== Testing nginx configuration ==="
    sudo nginx -t
    
    echo ""
    echo "=== Checking if website files exist ==="
    ls -la /var/www/test.zagent.ps/ | head -10
    
    echo ""
    echo "=== Checking nginx status ==="
    sudo systemctl status nginx --no-pager | head -10
    
    echo ""
    echo "=== Checking if port 80 is listening ==="
    sudo netstat -tlnp | grep :80 || sudo ss -tlnp | grep :80
EOF

echo ""
echo "✅ Check complete!"

