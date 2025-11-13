#!/bin/bash
# Extract version and build from pubspec.yaml

set -e
set -o pipefail
# set -x  # debug

# Get script directory
SCRIPT_DIR=$(dirname "$0")

# Use absolute path to pubspec.yaml
PUBSPEC="$SCRIPT_DIR/../pubspec.yaml"

VERSION_LINE=$(grep '^version:' "$PUBSPEC" | head -n 1)
VERSION=$(echo "$VERSION_LINE" | cut -d '+' -f1 | awk '{print $2}')
BUILD_NUMBER=$(echo "$VERSION_LINE" | cut -d '+' -f2)

echo "VERSION=$VERSION"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "FULL_VERSION=$VERSION+$BUILD_NUMBER"

# GitHub Actions outputs
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "version=$VERSION" >> $GITHUB_OUTPUT
  echo "build=$BUILD_NUMBER" >> $GITHUB_OUTPUT
fi
