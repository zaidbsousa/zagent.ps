#!/bin/bash

# Set up nginx configuration for library.zagent.ps
# Usage: ./setup-nginx-library.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-nginx-library.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-nginx-library.sh 72.60.188.157"
    exit 1
fi

echo "🔧 Setting up nginx configuration for library.zagent.ps..."

ssh $USERNAME@$VPS_IP << 'NGINX_SETUP_EOF'
    # Backup existing config if it exists
    if [ -f /etc/nginx/sites-available/library.zagent.ps ]; then
        sudo cp /etc/nginx/sites-available/library.zagent.ps /etc/nginx/sites-available/library.zagent.ps.backup.$(date +%Y%m%d_%H%M%S)
        echo "✅ Backed up existing config"
    fi
    
    # Create nginx config
    sudo tee /etc/nginx/sites-available/library.zagent.ps > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    server_name library.zagent.ps;
    
    root /var/www/library.zagent.ps;
    index library.html index.html;
    
    # HTTP Basic Authentication (uncomment after running setup-library-auth.sh)
    # auth_basic "zAgent Library - Client Access Only";
    # auth_basic_user_file /etc/nginx/auth/library.users;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# HTTP to HTTPS redirect (uncomment after SSL setup)
# server {
#     listen 80;
#     server_name library.zagent.ps;
#     return 301 https://$server_name$request_uri;
# }
NGINX_CONFIG
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/library.zagent.ps /etc/nginx/sites-enabled/library.zagent.ps
    
    # Test configuration
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
NGINX_SETUP_EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Nginx configuration setup complete!"
    echo "🌐 Your site will be available at: http://library.zagent.ps"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Set up authentication: ./setup-library-auth.sh $VPS_IP $USERNAME basic"
    echo "   2. Set up SSL: ./setup-ssl-library.sh $VPS_IP $USERNAME"
    echo "   3. Deploy library: ./deploy-library.sh $VPS_IP $USERNAME"
else
    echo "❌ Setup failed. Please check the errors above."
fi

