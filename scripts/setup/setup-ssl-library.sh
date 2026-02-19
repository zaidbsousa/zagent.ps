#!/bin/bash

# Set up SSL for library.zagent.ps
# Usage: ./setup-ssl-library.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-ssl-library.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-ssl-library.sh 72.60.188.157"
    exit 1
fi

echo "🔒 Setting up SSL for library.zagent.ps..."

ssh $USERNAME@$VPS_IP << 'SSL_EOF'
    # Install certbot if not installed
    if ! command -v certbot &> /dev/null; then
        echo "📦 Installing certbot..."
        sudo apt-get update -qq
        sudo apt-get install -y certbot python3-certbot-nginx
    fi
    
    # Get SSL certificate
    echo "🔐 Obtaining SSL certificate..."
    sudo certbot --nginx -d library.zagent.ps --non-interactive --agree-tos --email mrzaid@zagent.ps
    
    # Update nginx config to redirect HTTP to HTTPS
    if [ -f /etc/nginx/sites-available/library.zagent.ps ]; then
        # Backup config
        sudo cp /etc/nginx/sites-available/library.zagent.ps /etc/nginx/sites-available/library.zagent.ps.backup.$(date +%Y%m%d_%H%M%S)
        
        # Add HTTP to HTTPS redirect
        sudo tee -a /etc/nginx/sites-available/library.zagent.ps > /dev/null << 'REDIRECT_CONFIG'

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name library.zagent.ps;
    return 301 https://$server_name$request_uri;
}
REDIRECT_CONFIG
    fi
    
    # Test and reload nginx
    sudo nginx -t && sudo systemctl reload nginx
    
    echo "✅ SSL setup complete!"
    echo "🔒 Your site is now available at: https://library.zagent.ps"
SSL_EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSL certificate installed successfully!"
    echo "🌐 Your library is now secure at: https://library.zagent.ps"
    echo ""
    echo "💡 Certificate will auto-renew via certbot"
else
    echo "❌ SSL setup failed. Please check the errors above."
fi

