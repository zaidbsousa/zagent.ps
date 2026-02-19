# Deployment Guide

## Deploying to test.zagent.ps

### Prerequisites
1. You have SSH access to your VPS
2. Your VPS IP address
3. Your website files ready to deploy

### Quick Start

1. **Place your website files** in a directory (or use the current directory)

2. **Run the deployment script:**
   ```bash
   ./deploy-test.sh YOUR_VPS_IP [username] [source_directory]
   ```

   Examples:
   ```bash
   # Deploy from current directory
   ./deploy-test.sh 72.60.188.157
   
   # Deploy with custom username
   ./deploy-test.sh 72.60.188.157 myuser
   
   # Deploy from a specific directory
   ./deploy-test.sh 72.60.188.157 root ./my-website
   ```

### Server Configuration (One-time setup)

Before deploying, make sure your VPS has nginx configured for `test.zagent.ps`:

1. **Create nginx configuration file:**
   ```bash
   sudo nano /etc/nginx/sites-available/test.zagent.ps
   ```

2. **Add this configuration:**
   ```nginx
   server {
       listen 80;
       server_name test.zagent.ps;
       
       root /var/www/test.zagent.ps;
       index index.html index.htm;
       
       location / {
           try_files $uri $uri/ =404;
       }
   }
   ```

3. **Enable the site:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/test.zagent.ps /etc/nginx/sites-enabled/
   sudo nginx -t  # Test configuration
   sudo systemctl reload nginx
   ```

4. **Set up SSL (optional but recommended):**
   ```bash
   ./setup-ssl-test.sh 72.60.188.157
   ```
   Or manually:
   ```bash
   sudo certbot --nginx -d test.zagent.ps
   ```

5. **Set up clean URLs (optional):**
   ```bash
   ./setup-nginx-clean-urls.sh 72.60.188.157
   ```
   This enables clean URLs like `/character/aya` instead of `/character.html?id=aya`

### What the script does

1. Uploads all files from your source directory to the VPS
2. Backs up existing files (if any)
3. Deploys new files to `/var/www/test.zagent.ps`
4. Sets proper permissions
5. Reloads nginx

## Available Scripts

- **`deploy-test.sh`** - Deploy website files to test.zagent.ps
- **`setup-nginx-test.sh`** - Initial nginx configuration setup
- **`setup-ssl-test.sh`** - Set up SSL/HTTPS with Let's Encrypt
- **`setup-nginx-clean-urls.sh`** - Configure clean URLs (removes .html from URLs)
- **`check-nginx-config.sh`** - Diagnostic tool to check nginx configuration

## Clean URLs

The website supports clean URLs:
- `https://test.zagent.ps/` (homepage)
- `https://test.zagent.ps/character/aya`
- `https://test.zagent.ps/character/atta`
- `https://test.zagent.ps/character/rawan`

Old URLs with query parameters still work for backwards compatibility.

### Troubleshooting

- **Permission denied**: Make sure your SSH key is set up or you have the password
- **nginx not found**: The script will try both `systemctl` and `service` commands
- **Files not appearing**: Check nginx configuration and ensure the server_name matches `test.zagent.ps`
- **404 errors on clean URLs**: Run `./setup-nginx-clean-urls.sh` to configure clean URL support
- **CSS not loading**: Make sure all asset paths in HTML/JS files use root-relative paths (starting with `/`)
