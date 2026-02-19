#!/bin/bash
# Deploy library page (public access, no authentication)
# Usage: ./deploy-library-public.sh YOUR_VPS_IP [username]

if [ -z "$1" ]; then
    echo "❌ Error: VPS IP address required"
    echo "Usage: ./deploy-library-public.sh YOUR_VPS_IP [username]"
    exit 1
fi

VPS_IP="$1"
USERNAME="${2:-root}"

echo "📦 Deploying library page..."
echo "📡 Connecting to $VPS_IP as $USERNAME..."
echo ""

# Deploy library files
echo "📋 Uploading library files..."
scp library/library.html "$USERNAME@$VPS_IP:/var/www/library.zagent.ps/library.html"
scp library/library.css "$USERNAME@$VPS_IP:/var/www/library.zagent.ps/library.css"
scp library/library.js "$USERNAME@$VPS_IP:/var/www/library.zagent.ps/library.js"

# Deploy assets if they exist
if [ -f library/assets/reve.jpg ]; then
    echo "📋 Uploading assets..."
    ssh "$USERNAME@$VPS_IP" "mkdir -p /var/www/library.zagent.ps/assets"
    scp library/assets/reve.jpg "$USERNAME@$VPS_IP:/var/www/library.zagent.ps/assets/reve.jpg"
fi

echo ""
echo "✅ Deployment complete!"
echo ""

