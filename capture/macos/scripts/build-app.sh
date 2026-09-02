#!/bin/bash
# Copyright (c) 2026 Standalone Bitwig Push contributors
# SPDX-License-Identifier: MIT

set -euo pipefail

usage() {
    echo "usage: build-app.sh --output-dir DIR --scratch-dir DIR" >&2
}

output_dir=""
scratch_dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-dir)
            [[ $# -ge 2 ]] || { usage; exit 64; }
            output_dir="$2"
            shift 2
            ;;
        --scratch-dir)
            [[ $# -ge 2 ]] || { usage; exit 64; }
            scratch_dir="$2"
            shift 2
            ;;
        *)
            usage
            exit 64
            ;;
    esac
done

[[ -n "$output_dir" && -n "$scratch_dir" ]] || { usage; exit 64; }

script_dir="$(cd "$(dirname "$0")" && pwd -P)"
package_dir="$(cd "$script_dir/.." && pwd -P)"
app_path="$output_dir/PushwigCaptureHelper.app"

if [[ -e "$app_path" ]]; then
    echo "error: output app already exists: $app_path" >&2
    exit 73
fi

mkdir -p "$output_dir" "$scratch_dir"

xcrun swift build \
    --package-path "$package_dir" \
    --scratch-path "$scratch_dir" \
    --configuration release \
    --product PushwigCaptureHelper

binary_dir="$(xcrun swift build \
    --package-path "$package_dir" \
    --scratch-path "$scratch_dir" \
    --configuration release \
    --show-bin-path)"
binary_path="$binary_dir/PushwigCaptureHelper"

[[ -x "$binary_path" ]] || { echo "error: release binary not found" >&2; exit 66; }

mkdir -p "$app_path/Contents/MacOS"
install -m 0755 "$binary_path" "$app_path/Contents/MacOS/PushwigCaptureHelper"
install -m 0644 "$package_dir/Resources/Info.plist" "$app_path/Contents/Info.plist"

plutil -lint "$app_path/Contents/Info.plist"
codesign --force --sign - --timestamp=none "$app_path"
codesign --verify --deep --strict --verbose=2 "$app_path"
codesign -dv --verbose=4 "$app_path" 2>&1
plutil -p "$app_path/Contents/Info.plist"
shasum -a 256 "$app_path/Contents/MacOS/PushwigCaptureHelper" "$app_path/Contents/Info.plist"

echo "APP_PATH=$app_path"
