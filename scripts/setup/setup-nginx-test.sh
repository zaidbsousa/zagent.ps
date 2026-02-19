#!/bin/bash

# Script to set up nginx configuration for test.zagent.ps
# Usage: ./setup-nginx-test.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-nginx-test.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-nginx-test.sh 72.60.188.157"
    exit 1
fi

echo "🔧 Setting up nginx configuration for test.zagent.ps..."

# Create nginx configuration on the server
ssh $USERNAME@$VPS_IP << 'EOF'
    # Create nginx config file
    cat > /tmp/test.zagent.ps.conf << 'NGINX_CONFIG'
server {
    listen 80;
    server_name test.zagent.ps;
    
    root /var/www/test.zagent.ps;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
NGINX_CONFIG

    # Move config to nginx sites-available
    sudo mv /tmp/test.zagent.ps.conf /etc/nginx/sites-available/test.zagent.ps
    
    # Create symlink to enable the site
    sudo ln -sf /etc/nginx/sites-available/test.zagent.ps /etc/nginx/sites-enabled/test.zagent.ps
    
    # Test nginx configuration
    echo "🧪 Testing nginx configuration..."
    sudo nginx -t
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx configuration is valid!"
        echo "🔄 Reloading nginx..."
        sudo systemctl reload nginx || sudo service nginx reload
        echo "✅ Nginx reloaded successfully!"
    else
        echo "❌ Nginx configuration test failed. Please check the errors above."
        exit 1
    fi
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Nginx configuration setup complete!"
    echo "🌐 Your site will be available at: http://test.zagent.ps"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Make sure DNS is pointing test.zagent.ps to your VPS IP"
    echo "   2. Deploy your website: ./deploy-test.sh $VPS_IP $USERNAME SDF_AI"
    echo "   3. (Optional) Set up SSL: ssh $USERNAME@$VPS_IP 'sudo certbot --nginx -d test.zagent.ps'"
else
    echo "❌ Setup failed. Please check the errors above."
fi
