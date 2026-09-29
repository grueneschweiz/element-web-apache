#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf -- "$TEST_ROOT"' EXIT
VERSION=v1.12.29

mkdir -p "${TEST_ROOT}/repo/scripts" "${TEST_ROOT}/upstream/element-${VERSION}/icons" \
    "${TEST_ROOT}/upstream/element-${VERSION}/bundles" "${TEST_ROOT}/site"
cp "${REPO_DIR}/scripts/deploy.sh" "${TEST_ROOT}/repo/scripts/"
printf 'my config\n' > "${TEST_ROOT}/repo/config.json"
printf 'my headers\n' > "${TEST_ROOT}/repo/.htaccess"
printf 'old install\n' > "${TEST_ROOT}/site/marker"
printf '<img src="icons/sample.svg">\n' > "${TEST_ROOT}/upstream/element-${VERSION}/index.html"
printf 'url("/icons/sample.svg")\n' > "${TEST_ROOT}/upstream/element-${VERSION}/bundles/styles.css"
printf 'url("../../icons/sample.svg")\n' > "${TEST_ROOT}/upstream/element-${VERSION}/bundles/relative.css"
printf '<svg/>\n' > "${TEST_ROOT}/upstream/element-${VERSION}/icons/sample.svg"
FIXTURE_ARCHIVE=${TEST_ROOT}/element.tar.gz
tar -czf "${FIXTURE_ARCHIVE}" -C "${TEST_ROOT}/upstream" "element-${VERSION}"
SHA256=$(sha256sum "${FIXTURE_ARCHIVE}")
SHA256=${SHA256%% *}
BAD_SHA256="0${SHA256:1}"
if [[ ${BAD_SHA256} == "${SHA256}" ]]; then
    BAD_SHA256="1${SHA256:1}"
fi

curl() {
    while [[ $# -gt 0 ]]; do
        if [[ $1 == --output ]]; then
            cp -- "${FIXTURE_ARCHIVE}" "$2"
            return
        fi
        shift
    done
    return 1
}
export FIXTURE_ARCHIVE
export -f curl
export ELEMENT_WEB_DEST=${TEST_ROOT}/site

if bash "${TEST_ROOT}/repo/scripts/deploy.sh" "${VERSION}" "${BAD_SHA256}" >/dev/null 2>&1; then
    echo "Incorrect checksum was accepted" >&2
    exit 1
fi
[[ -f ${TEST_ROOT}/site/marker && ! -e ${TEST_ROOT}/site/index.html ]]

bash "${TEST_ROOT}/repo/scripts/deploy.sh" "${VERSION}" "${SHA256}"
[[ ! -e ${TEST_ROOT}/site/marker && ! -d ${TEST_ROOT}/site/icons ]]
[[ -f ${TEST_ROOT}/site/ui-icons/sample.svg ]]
grep -q 'ui-icons/sample.svg' "${TEST_ROOT}/site/index.html"
grep -q 'ui-icons/sample.svg' "${TEST_ROOT}/site/bundles/styles.css"
grep -q '../../ui-icons/sample.svg' "${TEST_ROOT}/site/bundles/relative.css"
grep -q 'my config' "${TEST_ROOT}/site/config.json"
grep -q 'my headers' "${TEST_ROOT}/site/.htaccess"

ELEMENT_WEB_DEST=${TEST_ROOT}/new-site bash "${TEST_ROOT}/repo/scripts/deploy.sh" "${VERSION}" "${SHA256}" >/dev/null
[[ -f ${TEST_ROOT}/new-site/index.html && -f ${TEST_ROOT}/new-site/.htaccess ]]
echo "Deployment checks passed"
