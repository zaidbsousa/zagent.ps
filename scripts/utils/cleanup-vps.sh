#!/bin/bash

# VPS Cleanup Script - Remove directories from VPS
# Usage: ./cleanup-vps.sh YOUR_VPS_IP DIRECTORY_NAME [username] [--no-backup]

VPS_IP=${1:-""}
DIR_NAME=${2:-""}
USERNAME=${3:-"root"}
NO_BACKUP=false

# Parse arguments
if [ "$3" == "--no-backup" ] || [ "$4" == "--no-backup" ]; then
    NO_BACKUP=true
fi
if [ "$3" != "--no-backup" ] && [ -n "$3" ] && [ "$3" != "root" ]; then
    USERNAME=$3
fi

if [ -z "$VPS_IP" ] || [ -z "$DIR_NAME" ]; then
    echo "Usage: ./cleanup-vps.sh YOUR_VPS_IP DIRECTORY_NAME [username] [--no-backup]"
    echo "Example: ./cleanup-vps.sh 72.60.188.157 galaxy-backend root --no-backup"
    exit 1
fi

echo "🧹 Cleaning up VPS at $VPS_IP..."
echo "📁 Removing directory: $DIR_NAME"
echo ""

# Check if directory exists and remove it
ssh -o StrictHostKeyChecking=accept-new $USERNAME@$VPS_IP << EOF
    WEB_DIR="/var/www/$DIR_NAME"
    
    if [ -d "\$WEB_DIR" ]; then
        echo "Found directory: \$WEB_DIR"
        size=\$(du -sh "\$WEB_DIR" 2>/dev/null | cut -f1)
        echo "Size: \$size"
        echo ""
        
        if [ "$NO_BACKUP" = "true" ]; then
            echo "⚠️  Removing without backup..."
            rm -rf "\$WEB_DIR"
            echo "✅ Directory removed: \$WEB_DIR"
        else
            echo "📦 Creating backup first..."
            backup_dir="\$WEB_DIR.backup.\$(date +%Y%m%d_%H%M%S)"
            mv "\$WEB_DIR" "\$backup_dir"
            echo "✅ Directory moved to backup: \$backup_dir"
            echo "   To remove backup: rm -rf \$backup_dir"
        fi
        
        # Remove corresponding nginx config if it exists
        if [ -f "/etc/nginx/sites-available/$DIR_NAME" ]; then
            echo ""
            echo "🔧 Removing nginx configuration..."
            sudo rm -f "/etc/nginx/sites-available/$DIR_NAME"
            sudo rm -f "/etc/nginx/sites-enabled/$DIR_NAME"
            
            # Test and reload nginx
            if sudo nginx -t >/dev/null 2>&1; then
                sudo systemctl reload nginx 2>/dev/null || sudo service nginx reload 2>/dev/null
                echo "✅ Nginx configs removed and nginx reloaded"
            else
                echo "⚠️  Nginx config removed but test failed - please check manually"
            fi
        fi
    else
        echo "❌ Directory not found: \$WEB_DIR"
        exit 1
    fi
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Cleanup complete!"
else
    echo ""
    echo "❌ Cleanup failed. Please check the errors above."
    exit 1
fi

