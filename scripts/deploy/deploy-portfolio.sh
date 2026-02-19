#!/bin/bash

# Deployment script for portfolio.zagent.ps subdomain
# Usage: ./deploy-portfolio.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}
SOURCE_DIR="./portfolio"
WEB_DIR="/var/www/portfolio.zagent.ps"

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./deploy-portfolio.sh YOUR_VPS_IP [username]"
    echo "Example: ./deploy-portfolio.sh 72.60.188.157"
    exit 1
fi

# Check if portfolio directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Portfolio directory '$SOURCE_DIR' does not exist"
    exit 1
fi

echo "🚀 Deploying portfolio to portfolio.zagent.ps on $VPS_IP..."

# Create temporary directory on server
ssh $USERNAME@$VPS_IP "mkdir -p /tmp/portfolio_deploy"

# Upload all files from portfolio directory
echo "📤 Uploading portfolio files..."
scp -r $SOURCE_DIR/* $USERNAME@$VPS_IP:/tmp/portfolio_deploy/

# Also upload the favicon to the portfolio directory
echo "📤 Uploading assets..."
if [ -f "../zAgent-favicon.png" ]; then
    scp ../zAgent-favicon.png $USERNAME@$VPS_IP:/tmp/portfolio_deploy/ 2>/dev/null || true
fi

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
    mv /tmp/portfolio_deploy/* $WEB_DIR/ 2>/dev/null || true
    # Handle hidden files
    mv /tmp/portfolio_deploy/.* $WEB_DIR/ 2>/dev/null || true
    # Copy favicon to parent directory if it exists in portfolio
    if [ -f "$WEB_DIR/zAgent-favicon.png" ]; then
        cp $WEB_DIR/zAgent-favicon.png /var/www/zAgent-favicon.png 2>/dev/null || true
    fi
    rm -rf /tmp/portfolio_deploy
    # Set permissions
    chown -R www-data:www-data $WEB_DIR
    chmod -R 755 $WEB_DIR
    # Reload nginx
    systemctl reload nginx || service nginx reload
EOF

echo "✅ Portfolio deployment complete!"
echo "🌐 Visit: https://portfolio.zagent.ps"
echo ""
echo "⚠️  Note: Make sure nginx is configured for portfolio.zagent.ps subdomain"
echo "   The server should have a config file like /etc/nginx/sites-available/portfolio.zagent.ps"

