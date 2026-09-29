#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_REPOSITORY:?}"
: "${GITHUB_SHA:?}"

RELEASE_JSON=$(mktemp)
NOTES_FILE=$(mktemp)
trap 'rm -f -- "$RELEASE_JSON" "$NOTES_FILE"' EXIT

gh api repos/element-hq/element-web/releases/latest > "${RELEASE_JSON}"
VERSION=$(jq -er '.tag_name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "${RELEASE_JSON}")
DIGEST=$(jq -er --arg name "element-${VERSION}.tar.gz" \
    '[.assets[] | select(.name == $name) | .digest | select(type == "string" and test("^sha256:[0-9a-f]{64}$"))] | if length == 1 then .[0] | ltrimstr("sha256:") else empty end' \
    "${RELEASE_JSON}")
TAG="element-web-${VERSION}"

if gh release view "${TAG}" --repo "${GITHUB_REPOSITORY}" >/dev/null 2>&1; then
    echo "Release ${TAG} already exists"
    exit 0
fi

{
    printf 'Upstream release: https://github.com/element-hq/element-web/releases/tag/%s\n\n' "${VERSION}"
    printf 'Archive: https://github.com/element-hq/element-web/releases/download/%s/element-%s.tar.gz\n' "${VERSION}" "${VERSION}"
    printf 'SHA-256: %s\n\n' "${DIGEST}"
    jq -er '.body | select(type == "string" and length > 0)' "${RELEASE_JSON}"
} > "${NOTES_FILE}"

gh release create "${TAG}" --repo "${GITHUB_REPOSITORY}" --target "${GITHUB_SHA}" \
    --title "Element Web ${VERSION}" --notes-file "${NOTES_FILE}"
