#!/bin/bash

# Script to set up SSL/HTTPS for test.zagent.ps using Let's Encrypt
# Usage: ./setup-ssl-test.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-ssl-test.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-ssl-test.sh 72.60.188.157"
    exit 1
fi

echo "🔒 Setting up SSL/HTTPS for test.zagent.ps..."

ssh $USERNAME@$VPS_IP << 'EOF'
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        echo "📦 Installing certbot..."
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
    else
        echo "✅ Certbot is already installed"
    fi
    
    # Check if nginx config exists
    if [ ! -f /etc/nginx/sites-available/test.zagent.ps ]; then
        echo "❌ Error: Nginx config for test.zagent.ps not found!"
        echo "   Please run setup-nginx-test.sh first"
        exit 1
    fi
    
    echo ""
    echo "🔐 Obtaining SSL certificate..."
    echo "   (You may be prompted for your email and to agree to terms)"
    echo ""
    
    # Run certbot to get SSL certificate
    sudo certbot --nginx -d test.zagent.ps --non-interactive --agree-tos --redirect
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ SSL certificate installed successfully!"
        echo "🌐 Your site is now available at: https://test.zagent.ps"
        echo ""
        echo "💡 Certificate will auto-renew. You can test renewal with:"
        echo "   sudo certbot renew --dry-run"
    else
        echo ""
        echo "❌ SSL setup failed. Common issues:"
        echo "   1. DNS not fully propagated"
        echo "   2. Port 80 not accessible from internet"
        echo "   3. Firewall blocking Let's Encrypt validation"
        exit 1
    fi
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSL setup complete!"
    echo "🔒 Visit: https://test.zagent.ps"
else
    echo ""
    echo "❌ SSL setup encountered an error. Check the output above."
fi

