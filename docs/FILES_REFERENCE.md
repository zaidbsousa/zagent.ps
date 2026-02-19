# zAgent Files Reference

Complete guide to all remaining files and their purposes.

> **Note:** Files have been reorganized. Scripts are now in `scripts/` folder, documentation in `docs/` folder.

## 📄 Core Website Files

### `index.html`
**Purpose:** Main landing page for `zagent.ps`  
**Use:** The homepage that visitors see when they visit https://zagent.ps  
**Contains:** Coming soon page with email subscription form, social links, and portfolio link

### `zAgent-logo.png`
**Purpose:** Main logo image for zAgent  
**Use:** Displayed on the landing page and used in social media previews

### `zAgent-favicon.png`
**Purpose:** Browser favicon (icon shown in browser tabs)  
**Use:** Automatically used by browsers when visiting zagent.ps

### `zAgent.mp4`
**Purpose:** Video asset (if used on the site)  
**Use:** Video content for the landing page or marketing materials

---

## 📚 Documentation Files

### `README.md`
**Purpose:** Main project documentation  
**Use:** Overview of the project, setup instructions, and general information

### `DEPLOYMENT.md`
**Purpose:** Deployment guide for `test.zagent.ps` subdomain  
**Use:** Instructions for deploying the SDF_AI project to test.zagent.ps  
**Contains:** Step-by-step deployment instructions, nginx setup, SSL setup

---

## 🚀 Deployment Scripts

### `scripts/deploy/deploy.sh`
**Purpose:** Deploy main zagent.ps landing page  
**Usage:** `./scripts/deploy/deploy.sh YOUR_VPS_IP [username]`  
**What it does:** Uploads `index.html` and assets to `/var/www/zagent.ps/` on the server

### `scripts/deploy/deploy-library-public.sh`
**Purpose:** Deploy library page (public, no authentication)  
**Usage:** `./scripts/deploy/deploy-library-public.sh YOUR_VPS_IP [username]`  
**What it does:** Uploads library files to `/var/www/library.zagent.ps/`  
**Files deployed:** `library.html`, `library.css`, `library.js`, and assets

### `scripts/deploy/deploy-portfolio.sh`
**Purpose:** Deploy portfolio page  
**Usage:** `./scripts/deploy/deploy-portfolio.sh YOUR_VPS_IP [username]`  
**What it does:** Uploads portfolio files to `/var/www/portfolio.zagent.ps/`  
**Files deployed:** `portfolio.html`, `portfolio.css`, and all portfolio images

### `scripts/deploy/deploy-test.sh`
**Purpose:** Deploy SDF_AI project to test.zagent.ps  
**Usage:** `./scripts/deploy/deploy-test.sh YOUR_VPS_IP [username] [source_directory]`  
**What it does:** Uploads SDF_AI project files to `/var/www/test.zagent.ps/`  
**Files deployed:** All files from SDF_AI directory

---

## ⚙️ Setup Scripts (Nginx Configuration)

### `scripts/setup/setup-nginx-library.sh`
**Purpose:** Initial nginx configuration for `library.zagent.ps`  
**Usage:** `./scripts/setup/setup-nginx-library.sh YOUR_VPS_IP [username]`  
**What it does:** Creates nginx config file for library subdomain (HTTP only)  
**When to use:** First time setting up library.zagent.ps

### `scripts/setup/setup-ssl-library.sh`
**Purpose:** Set up SSL/HTTPS for `library.zagent.ps`  
**Usage:** `./scripts/setup/setup-ssl-library.sh YOUR_VPS_IP [username]`  
**What it does:** Installs Certbot, obtains Let's Encrypt certificate, configures HTTPS  
**When to use:** After nginx setup, to enable HTTPS

### `scripts/setup/setup-nginx-portfolio.sh`
**Purpose:** Initial nginx configuration for `portfolio.zagent.ps`  
**Usage:** `./scripts/setup/setup-nginx-portfolio.sh YOUR_VPS_IP [username]`  
**What it does:** Creates nginx config file for portfolio subdomain (HTTP only)  
**When to use:** First time setting up portfolio.zagent.ps

### `scripts/setup/setup-ssl-portfolio.sh`
**Purpose:** Set up SSL/HTTPS for `portfolio.zagent.ps`  
**Usage:** `./scripts/setup/setup-ssl-portfolio.sh YOUR_VPS_IP [username]`  
**What it does:** Installs Certbot, obtains Let's Encrypt certificate, configures HTTPS  
**When to use:** After nginx setup, to enable HTTPS

### `scripts/setup/setup-nginx-test.sh`
**Purpose:** Initial nginx configuration for `test.zagent.ps`  
**Usage:** `./scripts/setup/setup-nginx-test.sh YOUR_VPS_IP [username]`  
**What it does:** Creates nginx config file for test subdomain (HTTP only)  
**When to use:** First time setting up test.zagent.ps for SDF_AI project

### `scripts/setup/setup-ssl-test.sh`
**Purpose:** Set up SSL/HTTPS for `test.zagent.ps`  
**Usage:** `./scripts/setup/setup-ssl-test.sh YOUR_VPS_IP [username]`  
**What it does:** Installs Certbot, obtains Let's Encrypt certificate, configures HTTPS  
**When to use:** After nginx setup, to enable HTTPS

---

## 🛠️ Utility Scripts

### `scripts/utils/check-nginx-config.sh`
**Purpose:** Check and display nginx configuration  
**Usage:** `./scripts/utils/check-nginx-config.sh YOUR_VPS_IP [username]`  
**What it does:** 
- Checks if nginx config files exist
- Displays nginx configuration
- Lists deployed files
- Useful for debugging and verification

---

## 📁 Project Directories

### `library/`
**Purpose:** AI Tools Library project  
**Contains:**
- `library.html` - Main library page (public access)
- `library.css` - Styles for library page
- `library.js` - JavaScript for search and filtering
- `assets/reve.jpg` - Image for Reve tool

**Deployed to:** `library.zagent.ps`

### `portfolio/`
**Purpose:** Portfolio showcase  
**Contains:**
- `portfolio.html` - Portfolio page
- `portfolio.css` - Portfolio styles
- `*.webp` - Portfolio project images (Ellarion, galaxyAI, etc.)

**Deployed to:** `portfolio.zagent.ps`

### `SDF_AI/`
**Purpose:** SDF AI podcast project  
**Contains:**
- `index.html` - Main page
- `character.html` - Character detail page
- `script.js`, `styles.css` - JavaScript and styles
- `character-data.js` - Character data
- `assets/` - Images, audio files, logos

**Deployed to:** `test.zagent.ps`

---

## 📋 Quick Reference

### First Time Setup (New Subdomain)
1. Run `scripts/setup/setup-nginx-[subdomain].sh` to configure nginx
2. Run `scripts/setup/setup-ssl-[subdomain].sh` to enable HTTPS
3. Run `scripts/deploy/deploy-[subdomain].sh` to upload files

### Regular Updates
- Just run the appropriate `scripts/deploy/deploy-*.sh` script to update files

### Troubleshooting
- Use `scripts/utils/check-nginx-config.sh` to verify nginx configuration

---

## 🎯 Summary

**Total Files:** ~20 scripts + 3 project directories

**Scripts by Category:**
- **Deployment:** 4 scripts (deploy.sh, deploy-library-public.sh, deploy-portfolio.sh, deploy-test.sh)
- **Setup:** 6 scripts (nginx + SSL for 3 subdomains)
- **Utility:** 1 script (check-nginx-config.sh)

**Project Directories:**
- **library/** - AI Tools Library (public)
- **portfolio/** - Portfolio showcase
- **SDF_AI/** - SDF AI podcast project

All files are organized and ready for use! 🚀

