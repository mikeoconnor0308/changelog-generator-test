#!/bin/bash
istrue () {
  case $1 in
    "true"|"yes"|"y") return 0;;
    *) return 1;;
  esac
}

set -e

# Go to GitHub workspace.
if [ -n "$GITHUB_WORKSPACE" ]; then
  cd "$GITHUB_WORKSPACE" || exit
fi

# Set repository from GitHub, if not set.
if [ -z "$INPUT_REPO" ]; then INPUT_REPO="$GITHUB_REPOSITORY"; fi
# Set user input from repository, if not set.
if [ -z "$INPUT_USER" ]; then INPUT_USER=$(echo "$INPUT_REPO" | cut -d / -f 1 ); fi
# Set project input from repository, if not set.
if [ -z "$INPUT_PROJECT" ]; then INPUT_PROJECT=$(echo "$INPUT_REPO" | cut -d / -f 2- ); fi

# Generate change log.
# shellcheck disable=SC2086 # We specifically want to allow word splitting.
github_changelog_generator \
  $ARG_USER \
  $ARG_PROJECT \
  $ARG_TOKEN

# Locate change log.
FILE="CHANGELOG.md"

# Save change log to outputs.
if [[ -e "$FILE" ]]; then
  CONTENT=$(cat "$FILE")
  echo ${CONTENT}
  # Escape as per https://github.community/t/set-output-truncates-multiline-strings/16852/3.
  CONTENT="${CONTENT//'%'/'%25'}"
  CONTENT="${CONTENT//$'\n'/'%0A'}"
  CONTENT="${CONTENT//$'\r'/'%0D'}"
  echo ::set-output name=changelog::"$CONTENT"
fi