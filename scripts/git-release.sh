#!/bin/bash

cd "$(git rev-parse --show-toplevel)" || exit 1

VERSION=$(grep '^version=' gradle.properties | cut -d'=' -f2)

echo "Releasing version: $VERSION"

# Check if the tag already exists
tag_exists=$(git tag -l "v")
if [ -n "$tag_exists" ]; then
  echo "Tag 'tag_exists' already exists. Skipping tag creation."
  exit 0
fi

# Check if the tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists."
else
  # Create and push the tag
  git tag -a "v$VERSION" -m "Release v$VERSION"
  git push origin "v$VERSION"

  echo "Tag v$VERSION created and pushed successfully."
fi