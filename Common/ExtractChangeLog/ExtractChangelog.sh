#!/bin/bash
# -----------------------------------------------------------------------------
# Extracts the changelog section for a specific version+build from dev_changelog.md.
#
# Usage:
#   ./extract_changelog.sh <VERSION> <BUILD_NUMBER>
#
# Example:
#   ./extract_changelog.sh 1.0.0 3
#
# How it works:
# - Combines VERSION and BUILD_NUMBER into a version key like "1.0.0+3".
# - Escapes regex-special characters for safe pattern matching.
# - Searches dev_changelog.md for a header matching:
#     - "# <version>:" or "## <version>:" or any number of '#' and spaces before it.
#     - Example valid headers:
#         # 1.0.0+3:
#         ##   2.1.5+12
# - Extracts all lines following that header until the next non-indented line.
# - Formats list items by converting "- " prefixes into "• ".
# - Outputs the result to both stdout and, if running in GitHub Actions,
#   to the $GITHUB_OUTPUT variable for later workflow use.
# -----------------------------------------------------------------------------

set -e
set -o pipefail
# set -x  # debug

VERSION="${1:?VERSION argument required}"
BUILD_NUMBER="${2:?BUILD_NUMBER argument required}"

SCRIPT_DIR=$(dirname "$0")
FILE_NAME="dev_changelog.md"
CHANGELOG_FILE="$SCRIPT_DIR/../$FILE_NAME"

VERSION_KEY="${VERSION}+${BUILD_NUMBER}"
echo "VERSION_KEY=$VERSION_KEY"

ESCAPED_VERSION_KEY=$(echo "$VERSION_KEY" | sed 's/[][\\.^$*+?{}|()]/\\&/g')
echo "ESCAPED_VERSION_KEY=$ESCAPED_VERSION_KEY"

if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "$FILE_NAME not found!"
  CHANGELOG="No changelog file found."
else
  CHANGELOG=$(awk '
    BEGIN {flag=0} 
    /^[\#]*[[:space:]]*'"$ESCAPED_VERSION_KEY"':*/ {flag=1; next} 
    /^[^[:space:]]/ && flag {flag=0} 
    flag {print}
  ' "$CHANGELOG_FILE" | sed 's/\r//' | sed 's/^[[:space:]]*-\s*/• /')

  if [ -z "$CHANGELOG" ]; then
    CHANGELOG="No changelog found for this version."
  fi
fi

echo "CHANGELOG:"
echo "$CHANGELOG"

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "changelog<<EOF" >> $GITHUB_OUTPUT
  echo "$CHANGELOG" >> $GITHUB_OUTPUT
  echo "EOF" >> $GITHUB_OUTPUT
fi
