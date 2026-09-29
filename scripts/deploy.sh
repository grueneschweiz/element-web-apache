#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 || ! $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ || ! $2 =~ ^[[:xdigit:]]{64}$ ]]; then
    echo "Usage: $0 vX.Y.Z SHA256" >&2
    exit 2
fi

VERSION=$1
EXPECTED_SHA256=$2
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
DEST=${ELEMENT_WEB_DEST:-${REPO_DIR}/processed}
DEST=${DEST%/}

if [[ ${DEST} != /* || -L ${DEST} || ( -e ${DEST} && ! -d ${DEST} ) ]]; then
    echo "Destination must be an absolute directory path, not a symlink: ${DEST}" >&2
    exit 2
fi

if [[ ! -f ${REPO_DIR}/config.json || ! -f ${REPO_DIR}/.htaccess ]]; then
    echo "Provide config.json and .htaccess in ${REPO_DIR} before deploying" >&2
    exit 2
fi

mkdir -p -- "$(dirname -- "${DEST}")"
WORK_DIR=$(mktemp -d "${DEST}.work.XXXXXXXX")
cleanup() {
    status=$?
    if [[ -d ${WORK_DIR}/previous && ! -e ${DEST} ]]; then
        mv -- "${WORK_DIR}/previous" "${DEST}"
    fi
    rm -rf -- "${WORK_DIR}"
    exit "${status}"
}
trap cleanup EXIT

ARCHIVE=${WORK_DIR}/element.tar.gz
curl -fL --retry 3 --output "${ARCHIVE}" \
    "https://github.com/element-hq/element-web/releases/download/${VERSION}/element-${VERSION}.tar.gz"
printf '%s  %s\n' "${EXPECTED_SHA256}" "${ARCHIVE}" | sha256sum --check --status

tar -xzf "${ARCHIVE}" -C "${WORK_DIR}"
SOURCE_DIR=${WORK_DIR}/element-${VERSION}
if [[ ! -f ${SOURCE_DIR}/index.html || ! -d ${SOURCE_DIR}/icons ]]; then
    echo "Unexpected Element Web archive layout" >&2
    exit 1
fi

mv -- "${SOURCE_DIR}" "${WORK_DIR}/site"
if [[ -d ${WORK_DIR}/site/bundles ]]; then
    find "${WORK_DIR}/site/bundles" -type f -name '*.css' \
        -exec sed -i 's|/icons/\([^\")]*\.svg\)|/ui-icons/\1|g' {} +
fi
sed -i 's|icons/\([^"'\''[:space:]]*\.svg\)|ui-icons/\1|g' "${WORK_DIR}/site/index.html"
mv -- "${WORK_DIR}/site/icons" "${WORK_DIR}/site/ui-icons"
cp -- "${REPO_DIR}/config.json" "${REPO_DIR}/.htaccess" "${WORK_DIR}/site/"

if [[ -d ${DEST} ]]; then
    mv -- "${DEST}" "${WORK_DIR}/previous"
fi
mv -- "${WORK_DIR}/site" "${DEST}"
echo "Deployed Element Web ${VERSION} to ${DEST}"
