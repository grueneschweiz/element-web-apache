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

1. backup your config.json file
2. Clone this repository to your hosting / server
3. create a symlink to the /processed folder to serve the application
4. whenever there's a new release, run git pull on your hosting / server
5. copy your config.json file back into the processed folder

## How the search / replace script works

The `scripts/rename.sh` script:
1. Copies the source files to the destination directory
2. Finds all CSS files and updates icon path references:
   - `/icons/` → `/ui-icons/`
   - `../../icons/` → `../../ui-icons/`
3. Updates `index.html` icon references
4. Renames the physical `icons/` directory to `ui-icons/`

## License

This repository contains automation scripts and workflows and is licensed under **AGPL-3.0**. The `processed/` folder contains files from [element-web](https://github.com/element-hq/element-web) and remains licensed under **AGPL** according to the upstream license.
