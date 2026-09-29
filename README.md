# Element Web on shared Apache hosting

Apache's server-level `/icons/` alias can hide [Element Web](https://github.com/element-hq/element-web)'s icons. This script deploys a chosen release with its icon directory and CSS/HTML references renamed to `/ui-icons/`. If you control the Apache virtual host, fix the alias there instead.

## Deploy

You need Bash, curl, tar and sha256sum on the host. Keep this checkout outside the web root.

1. Put your Element `config.json` in the checkout root. You can start from `config.sample.json` in the Element Web release archive.
2. Run `cp .htaccess.example .htaccess` and adjust it if needed. These two local files are copied into every deployment.
3. Pick a version and copy the archive's SHA-256 digest from [this repository's releases](https://github.com/grueneschweiz/element-web-apache/releases) or the [upstream releases](https://github.com/element-hq/element-web/releases) page (without `sha256:`).
4. Run:

   ```sh
   ./scripts/deploy.sh v1.12.29 17431dd1853032f55257e5155979396758dbf2e98d969407612a4f320865ff87
   ```

The result goes to `processed/`. Serve that directory as the site root, for example with a symlink from your web root. To use another **dedicated** directory, set `ELEMENT_WEB_DEST` to its absolute path. Deploy the next version by rerunning the command with its version and digest; no build files are committed to Git.

The archive is checked before the live directory is replaced. The digest checks the download against the release page, not the authenticity of that page. The `.htaccess` sets one-day caching for ordinary assets, no-cache for HTML, config, service worker and translations, and immutable caching for hashed bundles (when `mod_headers` is available).

This repository publishes a GitHub release for each new upstream version it detects, linking to the upstream changelog and listing the archive SHA-256. You can also run the workflow manually. Releases contain no build files. Run `bash tests/deploy.sh` and `bash tests/release.sh` for offline checks.

## License

The automation is AGPL-3.0. Deployed Element Web files retain their upstream license.
