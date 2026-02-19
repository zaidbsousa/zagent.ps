#!/bin/bash

# VPS Investigation Script - Run this directly on your VPS
# This script checks nginx conflicts, orphaned configs, and provides cleanup recommendations

echo "🔍 === VPS INVESTIGATION ==="
echo ""

echo "📁 === WEB DIRECTORIES ==="
echo ""
if [ -d "/var/www" ]; then
    echo "Directory sizes:"
    for dir in /var/www/*; do
        if [ -d "$dir" ]; then
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "  $(basename $dir): $size ($file_count files)"
        fi
    done
else
    echo "  ❌ /var/www directory does not exist"
fi
echo ""

echo "🌐 === NGINX CONFIGURATION ==="
echo ""
echo "Available nginx sites:"
ls -1 /etc/nginx/sites-available/ 2>/dev/null | grep -v "^default$" | while read site; do
    echo "  - $site"
done
echo ""

echo "Enabled nginx sites:"
ls -1 /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^default$" | while read site; do
    echo "  ✓ $site"
done
echo ""

echo "🔍 === SERVER NAME ANALYSIS ==="
echo ""
echo "All server_name directives:"
grep -r "server_name" /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^#" | while read line; do
    config_file=$(echo "$line" | cut -d: -f1 | xargs basename)
    server_line=$(echo "$line" | cut -d: -f2- | sed 's/^[[:space:]]*//')
    echo "  $config_file: $server_line"
done
echo ""

echo "🧪 === NGINX TEST ==="
echo ""
nginx -t 2>&1
echo ""

echo "💡 === ORPHANED CONFIGS (config exists but directory missing) ==="
echo ""
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        config_name=$(basename "$config")
        root_dir=$(grep "root" "$config" 2>/dev/null | head -1 | awk '{print $2}' | tr -d ';')
        if [ -n "$root_dir" ] && [ ! -d "$root_dir" ]; then
            echo "  ⚠️  $config_name -> $root_dir (directory missing)"
        fi
    fi
done
echo ""

echo "💡 === DIRECTORIES WITHOUT CONFIGS ==="
echo ""
if [ -d "/var/www" ]; then
    for dir in /var/www/*; do
        if [ -d "$dir" ]; then
            dir_name=$(basename "$dir")
            if [ "$dir_name" != "html" ] && [ ! -f "/etc/nginx/sites-available/$dir_name" ]; then
                size=$(du -sh "$dir" 2>/dev/null | cut -f1)
                echo "  ⚠️  $dir_name ($size) - no nginx config"
            fi
        fi
    done
fi
echo ""

echo "🗂️  === BACKUP DIRECTORIES ==="
echo ""
backup_dirs=$(find /var/www -type d -name "*.backup" 2>/dev/null)
if [ -n "$backup_dirs" ]; then
    echo "Found backup directories:"
    echo "$backup_dirs" | while read dir; do
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo "  - $dir ($size)"
    done
else
    echo "  No backup directories found"
fi
echo ""

echo "💾 === DISK USAGE ==="
echo ""
df -h / | tail -1 | awk '{print "  Root: " $3 " used of " $2 " (" $5 " used)"}'
if [ -d "/var/www" ]; then
    www_size=$(du -sh /var/www 2>/dev/null | cut -f1)
    echo "  /var/www total: $www_size"
fi
echo ""

echo "✅ Investigation complete!"

