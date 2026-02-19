# zAgent.ps

A modern "Coming Soon" landing page for zAgent, featuring a minimalist code editor design with an animated neural network background.

## 📁 Project Structure

```
zAgent/
├── index.html              # Main landing page
├── zAgent-logo.png         # Main logo
├── zAgent-favicon.png      # Browser favicon
├── zAgent.mp4              # Video asset
│
├── scripts/                # All deployment and setup scripts
│   ├── deploy/            # Deployment scripts
│   │   ├── deploy.sh                      # Deploy main zagent.ps
│   │   ├── deploy-library-public.sh       # Deploy library page
│   │   ├── deploy-portfolio.sh            # Deploy portfolio page
│   │   └── deploy-test.sh                 # Deploy SDF_AI project
│   │
│   ├── setup/              # Setup scripts
│   │   ├── setup-nginx-library.sh        # Nginx config for library
│   │   ├── setup-ssl-library.sh          # SSL setup for library
│   │   ├── setup-nginx-portfolio.sh       # Nginx config for portfolio
│   │   ├── setup-ssl-portfolio.sh         # SSL setup for portfolio
│   │   ├── setup-nginx-test.sh            # Nginx config for test subdomain
│   │   └── setup-ssl-test.sh             # SSL setup for test subdomain
│   │
│   └── utils/              # Utility scripts
│       └── check-nginx-config.sh          # Check nginx configuration
│
├── docs/                   # Documentation
│   ├── README.md           # Detailed project documentation
│   ├── DEPLOYMENT.md       # Deployment guide for test.zagent.ps
│   └── FILES_REFERENCE.md  # Complete files reference
│
├── library/                # AI Tools Library project
│   ├── library.html
│   ├── library.css
│   ├── library.js
│   └── assets/
│
├── portfolio/              # Portfolio showcase
│   ├── portfolio.html
│   ├── portfolio.css
│   └── *.webp (images)
│
└── SDF_AI/                # SDF AI podcast project
    ├── index.html
    ├── character.html
    ├── script.js
    ├── styles.css
    └── assets/
```

## 🚀 Quick Start

### Deploy Main Landing Page
```bash
./scripts/deploy/deploy.sh YOUR_VPS_IP [username]
```

### Deploy Library
```bash
# 1. Setup nginx (first time only)
./scripts/setup/setup-nginx-library.sh YOUR_VPS_IP [username]

# 2. Setup SSL (first time only)
./scripts/setup/setup-ssl-library.sh YOUR_VPS_IP [username]

# 3. Deploy files
./scripts/deploy/deploy-library-public.sh YOUR_VPS_IP [username]
```

### Deploy Portfolio
```bash
# 1. Setup nginx (first time only)
./scripts/setup/setup-nginx-portfolio.sh YOUR_VPS_IP [username]

# 2. Setup SSL (first time only)
./scripts/setup/setup-ssl-portfolio.sh YOUR_VPS_IP [username]

# 3. Deploy files
./scripts/deploy/deploy-portfolio.sh YOUR_VPS_IP [username]
```

## 📚 Documentation

See `docs/` folder for detailed documentation:
- `docs/README.md` - Full project documentation
- `docs/DEPLOYMENT.md` - Deployment guide
- `docs/FILES_REFERENCE.md` - Complete files reference

## 🛠️ Utilities

Check nginx configuration:
```bash
./scripts/utils/check-nginx-config.sh YOUR_VPS_IP [username]
```

## 🌐 Subdomains

- **zagent.ps** - Main landing page
- **library.zagent.ps** - AI Tools Library (public)
- **portfolio.zagent.ps** - Portfolio showcase
- **test.zagent.ps** - SDF AI podcast project

## 📝 Features

- **Code Editor Aesthetic**: Clean, minimalist design
- **Animated Background**: Interactive neural network visualization
- **Responsive Design**: Works on all devices
- **RTL Support**: Right-to-left layout for Arabic content
- **Typing Animation**: Dynamic text typing effect

## 🔧 Technologies

- Pure HTML, CSS, and JavaScript
- Canvas API for animations
- Google Fonts (Cairo)
- No dependencies or build tools required

