#!/bin/bash

# Script to set up nginx configuration for portfolio.zagent.ps
# Usage: ./setup-nginx-portfolio.sh YOUR_VPS_IP [username]

VPS_IP=${1:-""}
USERNAME=${2:-"root"}

if [ -z "$VPS_IP" ]; then
    echo "Usage: ./setup-nginx-portfolio.sh YOUR_VPS_IP [username]"
    echo "Example: ./setup-nginx-portfolio.sh 72.60.188.157"
    exit 1
fi

echo "🔧 Setting up nginx configuration for portfolio.zagent.ps..."

# Create nginx configuration on the server
ssh $USERNAME@$VPS_IP << 'EOF'
    # Create nginx config file
    cat > /tmp/portfolio.zagent.ps.conf << 'NGINX_CONFIG'
server {
    listen 80;
    server_name portfolio.zagent.ps 72.60.188.157;
    
    root /var/www/portfolio.zagent.ps;
    index portfolio.html index.html index.htm;
    
    location / {
        try_files $uri $uri/ /portfolio.html =404;
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
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_CONFIG

    # Move config to nginx sites-available
    sudo mv /tmp/portfolio.zagent.ps.conf /etc/nginx/sites-available/portfolio.zagent.ps
    
    # Create symlink to enable the site
    sudo ln -sf /etc/nginx/sites-available/portfolio.zagent.ps /etc/nginx/sites-enabled/portfolio.zagent.ps
    
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
    echo ""
    echo "📝 Next steps:"
    echo "   1. Set up SSL certificate:"
    echo "      ./setup-ssl-portfolio.sh $VPS_IP"
    echo "   2. Deploy your portfolio:"
    echo "      ./deploy-portfolio.sh $VPS_IP"
else
    echo "❌ Setup failed. Please check the errors above."
    exit 1
fi

