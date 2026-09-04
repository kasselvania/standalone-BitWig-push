#!/bin/bash
# Copyright (c) 2026 Standalone Bitwig Push contributors
# SPDX-License-Identifier: MIT

set -euo pipefail
[[ $# -eq 2 ]] || { echo "usage: build-app.sh OUTPUT_DIR SCRATCH_DIR" >&2; exit 64; }
output_dir="$1"
scratch_dir="$2"
package_dir="$(cd "$(dirname "$0")" && pwd -P)"
app="$output_dir/PushwigQuadrantFixture.app"
[[ ! -e "$app" ]] || { echo "error: output exists: $app" >&2; exit 73; }
mkdir -p "$output_dir" "$scratch_dir"
export CLANG_MODULE_CACHE_PATH="$scratch_dir/clang-module-cache"
export SWIFT_MODULE_CACHE_PATH="$scratch_dir/swift-module-cache"
xcrun swift build --disable-sandbox --package-path "$package_dir" --scratch-path "$scratch_dir" \
  --configuration release --product PushwigQuadrantFixture
binary_dir="$(xcrun swift build --disable-sandbox --package-path "$package_dir" --scratch-path "$scratch_dir" \
  --configuration release --show-bin-path)"
mkdir -p "$app/Contents/MacOS"
install -m 0755 "$binary_dir/PushwigQuadrantFixture" "$app/Contents/MacOS/"
install -m 0644 "$package_dir/Info.plist" "$app/Contents/Info.plist"
codesign --force --sign - --timestamp=none "$app"
codesign --verify --deep --strict "$app"
echo "APP_PATH=$app"
