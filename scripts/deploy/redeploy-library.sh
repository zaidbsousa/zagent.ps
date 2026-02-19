#!/bin/bash
# Complete library redeployment script
# This script sets up nginx, SSL, and deploys library files from scratch
# Usage: ./redeploy-library.sh YOUR_VPS_IP [username]

if [ -z "$1" ]; then
    echo "❌ Error: VPS IP address required"
    echo "Usage: ./redeploy-library.sh YOUR_VPS_IP [username]"
    echo "Example: ./redeploy-library.sh 72.60.188.157 root"
    exit 1
fi

VPS_IP="$1"
USERNAME="${2:-root}"

echo "🚀 Redeploying Library from Scratch"
echo "===================================="
echo "📡 Server: $VPS_IP"
echo "👤 User: $USERNAME"
echo ""

# Step 1: Setup Nginx
echo "📋 Step 1/3: Setting up Nginx configuration..."
echo ""
if ./scripts/setup/setup-nginx-library.sh "$VPS_IP" "$USERNAME"; then
    echo "✅ Nginx configuration complete"
else
    echo "❌ Nginx setup failed!"
    exit 1
fi
echo ""

# Step 2: Setup SSL
echo "📋 Step 2/3: Setting up SSL/HTTPS..."
echo ""
if ./scripts/setup/setup-ssl-library.sh "$VPS_IP" "$USERNAME"; then
    echo "✅ SSL setup complete"
else
    echo "❌ SSL setup failed!"
    exit 1
fi
echo ""

# Step 3: Deploy files
echo "📋 Step 3/3: Deploying library files..."
echo ""
if ./scripts/deploy/deploy-library-public.sh "$VPS_IP" "$USERNAME"; then
    echo "✅ Files deployed successfully"
else
    echo "❌ Deployment failed!"
    exit 1
fi
echo ""

echo "===================================="
echo "✅ Library Redeployment Complete!"
echo "===================================="
echo ""
echo "🌐 Your library is now available at:"
echo "   https://library.zagent.ps"
echo ""
echo "📝 Next steps:"
echo "   - Verify the site is accessible"
echo "   - Check that all images and assets load correctly"
echo ""

