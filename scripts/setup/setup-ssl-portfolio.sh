#!/bin/bash

# Script to set up SSL/HTTPS for portfolio.zagent.ps
# Usage: ./setup-ssl-portfolio.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-ssl-portfolio.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-ssl-portfolio.sh 72.60.188.157"
    exit 1
fi

echo "🔒 Setting up SSL certificate for portfolio.zagent.ps..."

# Run certbot on the server
ssh $USERNAME@$VPS_IP << 'EOF'
    echo "📋 Installing certbot if not already installed..."
    sudo apt-get update -qq
    sudo apt-get install -y certbot python3-certbot-nginx -qq
    
    echo "🔐 Obtaining SSL certificate..."
    sudo certbot --nginx -d portfolio.zagent.ps --non-interactive --agree-tos --email mrzaid@zagent.ps --redirect
    
    if [ $? -eq 0 ]; then
        echo "✅ SSL certificate installed successfully!"
        echo "🔄 Reloading nginx..."
        sudo systemctl reload nginx || sudo service nginx reload
        echo "✅ Nginx reloaded!"
    else
        echo "❌ SSL certificate installation failed."
        exit 1
    fi
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSL setup complete!"
    echo "🌐 Your portfolio is now available at: https://portfolio.zagent.ps"
else
    echo "❌ SSL setup failed. Please check the errors above."
    exit 1
fi

