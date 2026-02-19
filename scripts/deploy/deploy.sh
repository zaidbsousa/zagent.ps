#!/bin/bash

# Simple deployment script for zAgent.ps
# Usage: ./deploy.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}
WEB_DIR="/var/www/zagent.ps"

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./deploy.sh YOUR_VPS_IP [username]"
    echo "Example: ./deploy.sh 72.60.188.157"
    exit 1
fi

echo "🚀 Deploying zAgent to $VPS_IP..."

# Upload essential files
scp index.html zAgent*.png zAgent.mp4 $USERNAME@$VPS_IP:/tmp/zagent_deploy/

# Move files and set permissions
ssh $USERNAME@$VPS_IP << EOF
    mkdir -p $WEB_DIR
    mv /tmp/zagent_deploy/* $WEB_DIR/
    rm -rf /tmp/zagent_deploy
    chown -R www-data:www-data $WEB_DIR
    chmod -R 755 $WEB_DIR
    systemctl reload nginx
EOF

echo "✅ Deployment complete!"
echo "🌐 Visit: https://zagent.ps"

