#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

if ! command -v rbenv >/dev/null 2>&1; then
  echo "rbenv not found. Install rbenv first." >&2
  exit 1
fi

# Initialize rbenv for this script run.
eval "$(rbenv init - bash)"

# Ensure native extensions can compile if needed.
SDKROOT="$(xcrun --show-sdk-path)"
export SDKROOT
export CPLUS_INCLUDE_PATH="$SDKROOT/usr/include/c++/v1"
export CXXFLAGS="-isysroot $SDKROOT -I$SDKROOT/usr/include/c++/v1"
export CFLAGS="-isysroot $SDKROOT"
export CPPFLAGS="-isysroot $SDKROOT -I$SDKROOT/usr/include/c++/v1"

bundle exec jekyll serve
