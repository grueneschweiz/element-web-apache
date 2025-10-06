# Element Web for Apache

This repository automatically syncs [Element Web](https://github.com/element-hq/element-web) releases and renames icon paths to avoid conflicts with Apache's `mod_alias` icon directory.

## Problem

Apache's `mod_alias` module typically maps `/icons/` to the server's icon directory (e.g., `/usr/share/apache2/icons/`). This conflicts with Element Web's `/icons/` directory, causing the application to fail loading its UI icons.

## Solution

This repository:
1. Automatically fetches the latest Element Web releases
2. Renames the `icons/` directory to `ui-icons/`
3. Updates all references in CSS and HTML files accordingly
4. Provides the processed files ready for Apache deployment

## Automated Workflow

The GitHub Actions workflow runs:
- **Every Monday and Thursday at 03:00 UTC**
- **Manually via workflow dispatch**

When a new Element Web release is detected:
1. Downloads the release tarball
2. Runs the rename script to process icon paths
3. Commits the processed files to the `processed/` directory
4. Creates a GitHub issue with the release notes
5. Tracks the version in `current-release.txt` to avoid duplicate processing

## Deployment

The processed Element Web files are available in the `processed/` directory. Deploy them to your Apache web server as you would normally deploy Element Web.

### Apache Configuration Example

```apache
<VirtualHost *:443>
    ServerName element.example.com
    
    DocumentRoot /var/www/element-web
    
    <Directory /var/www/element-web>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    
    # SSL configuration
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
</VirtualHost>
```

## Manual Processing

To manually process a specific Element Web release:

```bash
# Download and extract Element Web
curl -L https://github.com/element-hq/element-web/releases/download/v1.12.0/element-v1.12.0.tar.gz -o element-web.tar.gz
tar -xzf element-web.tar.gz

# Run the rename script
./scripts/rename.sh ./element-v1.12.0 ./processed
```

## How It Works

The `scripts/rename.sh` script:
1. Copies the source files to the destination directory
2. Finds all CSS files and updates icon path references:
   - `/icons/` → `/ui-icons/`
   - `../../icons/` → `../../ui-icons/`
3. Updates `index.html` icon references
4. Renames the physical `icons/` directory to `ui-icons/`

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── sync-element-web.yml    # Automated sync workflow
├── processed/                       # Processed Element Web files
├── scripts/
│   └── rename.sh                   # Icon path renaming script
└── current-release.txt             # Tracks the current version
```

## License

This repository contains automation scripts and workflows. The Element Web application itself is licensed under the Apache License 2.0. See the [Element Web repository](https://github.com/element-hq/element-web) for details.
