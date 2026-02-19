#!/bin/bash

# Deployment script for test.zagent.ps subdomain
# Usage: ./deploy-test.sh YOUR_VPS_IP [username] [source_directory]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}
SOURCE_DIR=${3:-"."}
WEB_DIR="/var/www/test.zagent.ps"

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./deploy-test.sh YOUR_VPS_IP [username] [source_directory]"
    echo "Example: ./deploy-test.sh 72.60.188.157"
    echo "Example: ./deploy-test.sh 72.60.188.157 root ./my-website"
    exit 1
fi

echo "🚀 Deploying to test.zagent.ps on $VPS_IP..."

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

# Create temporary directory on server
ssh $USERNAME@$VPS_IP "mkdir -p /tmp/test_zagent_deploy"

# Upload all files from source directory
echo "📤 Uploading files..."
scp -r $SOURCE_DIR/* $USERNAME@$VPS_IP:/tmp/test_zagent_deploy/

# Move files and set permissions
echo "📁 Setting up files on server..."
ssh $USERNAME@$VPS_IP << EOF
    mkdir -p $WEB_DIR
    # Backup existing files if they exist
    if [ -d "$WEB_DIR" ] && [ "\$(ls -A $WEB_DIR 2>/dev/null)" ]; then
        echo "📦 Backing up existing files..."
        mkdir -p $WEB_DIR.backup
        cp -r $WEB_DIR/* $WEB_DIR.backup/ 2>/dev/null || true
    fi
    # Remove old files
    rm -rf $WEB_DIR/*
    # Move new files
    mv /tmp/test_zagent_deploy/* $WEB_DIR/ 2>/dev/null || true
    # Handle hidden files
    mv /tmp/test_zagent_deploy/.* $WEB_DIR/ 2>/dev/null || true
    rm -rf /tmp/test_zagent_deploy
    # Set permissions
    chown -R www-data:www-data $WEB_DIR
    chmod -R 755 $WEB_DIR
    # Reload nginx
    systemctl reload nginx || service nginx reload
EOF

echo "✅ Deployment complete!"
echo "🌐 Visit: https://test.zagent.ps"
echo ""
echo "⚠️  Note: Make sure nginx is configured for test.zagent.ps subdomain"
echo "   The server should have a config file like /etc/nginx/sites-available/test.zagent.ps"

