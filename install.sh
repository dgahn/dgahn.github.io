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

RUBY_VERSION="2.7.8"
BUNDLER_VERSION="1.17.2"

if ! rbenv versions --bare | grep -qx "$RUBY_VERSION"; then
  echo "Installing Ruby $RUBY_VERSION (this may take a while)..."
  rbenv install "$RUBY_VERSION"
fi

rbenv local "$RUBY_VERSION"

# Ensure the SDK include path is available for native extensions.
SDKROOT="$(xcrun --show-sdk-path)"
export SDKROOT
export CPLUS_INCLUDE_PATH="$SDKROOT/usr/include/c++/v1"
export CXXFLAGS="-isysroot $SDKROOT -I$SDKROOT/usr/include/c++/v1"
export CFLAGS="-isysroot $SDKROOT"
export CPPFLAGS="-isysroot $SDKROOT -I$SDKROOT/usr/include/c++/v1"

# Install the locked bundler version.
if ! gem list -i bundler -v "$BUNDLER_VERSION" >/dev/null 2>&1; then
  gem install bundler -v "$BUNDLER_VERSION"
fi

# Preinstall unf_ext to avoid missing C++ headers during bundle install.
if ! gem list -i unf_ext -v 0.0.8.2 >/dev/null 2>&1; then
  gem install unf_ext -v 0.0.8.2 -- --with-cppflags="$CPPFLAGS"
fi

bundle _${BUNDLER_VERSION}_ install

echo "Done. Use 'bundle exec jekyll serve' to run the site."
