#!/bin/bash

# Check for nginx configuration conflicts
# Usage: ./check-nginx-conflicts.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./check-nginx-conflicts.sh YOUR_VPS_IP [username]"
    echo "Example: ./check-nginx-conflicts.sh 72.60.188.157"
    exit 1
fi

echo "🔍 Checking nginx configuration conflicts..."
echo ""

ssh -o StrictHostKeyChecking=accept-new $USERNAME@$VPS_IP << 'EOF'
    echo "📋 === NGINX CONFIGURATION FILES ==="
    echo ""
    
    if [ -d "/etc/nginx/sites-available" ]; then
        echo "Available configs:"
        for config in /etc/nginx/sites-available/*; do
            if [ -f "$config" ]; then
                basename "$config"
            fi
        done
        echo ""
        
        echo "Enabled configs:"
        for config in /etc/nginx/sites-enabled/*; do
            if [ -f "$config" ]; then
                echo "  ✓ $(basename $config)"
            fi
        done
        echo ""
    fi
    
    echo "🔍 === SERVER NAME ANALYSIS ==="
    echo ""
    echo "Checking for duplicate server_name directives..."
    
    # Extract all server_name values
    server_names=$(grep -r "server_name" /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^#" | sed 's/.*server_name//' | tr ';' '\n' | tr ' ' '\n' | grep -v "^$" | sort | uniq -d)
    
    if [ -n "$server_names" ]; then
        echo "⚠️  Found potential conflicts:"
        echo "$server_names" | while read name; do
            echo "  - $name"
            echo "    Found in:"
            grep -r "server_name.*$name" /etc/nginx/sites-enabled/ 2>/dev/null | sed 's/^/      /'
        done
    else
        echo "  ✓ No duplicate server_name found"
    fi
    echo ""
    
    echo "📝 === ALL SERVER NAMES ==="
    echo ""
    grep -r "server_name" /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^#" | while read line; do
        config_file=$(echo "$line" | cut -d: -f1)
        server_line=$(echo "$line" | cut -d: -f2-)
        echo "  $(basename $config_file): $server_line"
    done
    echo ""
    
    echo "🧪 === NGINX TEST ==="
    echo ""
    sudo nginx -t 2>&1
    echo ""
    
    echo "💡 === RECOMMENDATIONS ==="
    echo ""
    
    # Check for orphaned configs (config exists but directory doesn't)
    echo "Checking for orphaned nginx configs (config exists but web directory missing):"
    for config in /etc/nginx/sites-enabled/*; do
        if [ -f "$config" ]; then
            config_name=$(basename "$config")
            # Try to extract root directory from config
            root_dir=$(grep "root" "$config" 2>/dev/null | head -1 | awk '{print $2}' | tr -d ';')
            if [ -n "$root_dir" ] && [ ! -d "$root_dir" ]; then
                echo "  ⚠️  $config_name -> $root_dir (directory missing)"
            fi
        fi
    done
    
    # Check for directories without configs
    echo ""
    echo "Checking for web directories without nginx configs:"
    if [ -d "/var/www" ]; then
        for dir in /var/www/*; do
            if [ -d "$dir" ]; then
                dir_name=$(basename "$dir")
                if [ "$dir_name" != "html" ] && [ ! -f "/etc/nginx/sites-available/$dir_name" ]; then
                    echo "  ⚠️  $dir_name (no nginx config)"
                fi
            fi
        done
    fi
EOF

echo ""
echo "✅ Analysis complete!"

