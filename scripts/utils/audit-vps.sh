#!/bin/bash

echo "🔍 VPS AUDIT REPORT"
echo "==================="
echo ""

echo "📁 WEB DIRECTORIES:"
du -sh /var/www/* 2>/dev/null | while read size dir; do
    file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
    echo "  $size - $(basename $dir) ($file_count files)"
done
echo ""

echo "🌐 NGINX SITES:"
echo "Available:"
ls -1 /etc/nginx/sites-available/ 2>/dev/null | grep -v "^default$"
echo ""
echo "Enabled:"
ls -1 /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^default$" | sed 's/^/  ✓ /'
echo ""

echo "🔒 SSL CERTIFICATES:"
if [ -d "/etc/letsencrypt/live" ]; then
    ls -1 /etc/letsencrypt/live/ 2>/dev/null | while read domain; do
        expiry=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/$domain/cert.pem 2>/dev/null | cut -d= -f2)
        echo "  ✓ $domain (expires: $expiry)"
    done
else
    echo "  No certificates found"
fi
echo ""

echo "🧪 NGINX STATUS:"
nginx -t 2>&1 | grep -E "(conflicting|syntax is|test is)" | sed 's/^/  /'
echo ""

echo "💾 DISK USAGE:"
df -h / | tail -1 | awk '{print "  Root: " $3 " used of " $2 " (" $5 " used)"}'
www_size=$(du -sh /var/www 2>/dev/null | cut -f1)
echo "  /var/www: $www_size"
echo ""

echo "🗂️  BACKUP DIRECTORIES:"
find /var/www -type d -name "*.backup" 2>/dev/null | while read dir; do
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "  $size - $dir"
done
[ -z "$(find /var/www -type d -name "*.backup" 2>/dev/null)" ] && echo "  None found"
echo ""

echo "⚠️  ISSUES:"
echo "Checking for orphaned configs (config exists but directory missing)..."
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        config_name=$(basename "$config")
        root_dir=$(grep "root" "$config" 2>/dev/null | head -1 | awk '{print $2}' | tr -d ';')
        if [ -n "$root_dir" ] && [ ! -d "$root_dir" ]; then
            echo "  ⚠️  $config_name -> $root_dir (directory missing)"
        fi
    fi
done
echo "Checking for directories without configs..."
for dir in /var/www/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        if [ "$dir_name" != "html" ] && [ ! -f "/etc/nginx/sites-available/$dir_name" ]; then
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo "  ⚠️  $dir_name ($size) - no nginx config"
        fi
    fi
done
echo ""

echo "✅ Audit complete!"
