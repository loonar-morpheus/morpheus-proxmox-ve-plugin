#!/bin/bash

cd "$(git rev-parse --show-toplevel)" || exit 1

VERSION=$(grep '^version=' gradle.properties | cut -d'=' -f2)

# Verifica se a tag já existe
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION já existe."
else
  git tag -a "v$VERSION" -m "Release v$VERSION"
  git push origin "v$VERSION"
  echo "Tag v$VERSION criada e enviada com sucesso."
fi