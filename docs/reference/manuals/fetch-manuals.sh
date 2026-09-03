#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-${SCRIPT_DIR}/local}"

BITWIG_GUIDE_URL="https://www.bitwig.com/media/bitwig_userguide/pdf/Bitwig_Studio_User_Guide_English_XfuP7Nz.pdf"
BITWIG_61_URL="https://downloads.bitwig.com/6.1/Release-Notes-6.1.pdf"
DBM_COMMIT="7e3416a1bdddbcbeec4e35e6531652e1618723de"
DBM_MANUAL_URL="https://raw.githubusercontent.com/kasselvania/DrivenByMoss/${DBM_COMMIT}/src/main/resources/Documentation/DrivenByMoss-Manual.pdf"

mkdir -p "${OUTPUT_DIR}"

download_pdf() {
  local url="$1"
  local destination="$2"
  local temporary="${destination}.partial"

  rm -f "${temporary}"
  printf 'Downloading %s\n' "$(basename "${destination}")"
  curl \
    --fail \
    --location \
    --retry 3 \
    --retry-delay 2 \
    --connect-timeout 20 \
    --output "${temporary}" \
    "${url}"

  local magic
  magic="$(LC_ALL=C head -c 5 "${temporary}")"
  if [[ "${magic}" != "%PDF-" ]]; then
    rm -f "${temporary}"
    printf 'Downloaded file is not a PDF: %s\n' "${url}" >&2
    exit 1
  fi

  mv "${temporary}" "${destination}"
}

download_pdf \
  "${BITWIG_GUIDE_URL}" \
  "${OUTPUT_DIR}/Bitwig-Studio-User-Guide.pdf"

download_pdf \
  "${BITWIG_61_URL}" \
  "${OUTPUT_DIR}/Bitwig-Studio-6.1-Quick-Guide.pdf"

download_pdf \
  "${DBM_MANUAL_URL}" \
  "${OUTPUT_DIR}/DrivenByMoss-Manual-accepted.pdf"

(
  cd "${OUTPUT_DIR}"
  shasum -a 256 \
    Bitwig-Studio-User-Guide.pdf \
    Bitwig-Studio-6.1-Quick-Guide.pdf \
    DrivenByMoss-Manual-accepted.pdf \
    > SHA256SUMS
)

printf '\nManuals downloaded to:\n%s\n\n' "${OUTPUT_DIR}"
cat "${OUTPUT_DIR}/SHA256SUMS"
