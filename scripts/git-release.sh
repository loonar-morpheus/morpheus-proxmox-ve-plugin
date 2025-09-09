#!/bin/bash


set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

VERSION=$(grep '^version=' gradle.properties | cut -d'=' -f2)
if [ -z "$VERSION" ]; then
  echo "Erro: versão não encontrada em gradle.properties."
  exit 1
fi

echo "Releasing version: $VERSION"

# Verifica se a tag já existe
if git rev-parse "refs/tags/$VERSION" >/dev/null 2>&1; then
  echo "Tag '$VERSION' já existe. Saindo."
  exit 0
fi

# Cria e envia a tag
if git tag -a "$VERSION" -m "Release v$VERSION"; then
  if git push origin "refs/tags/$VERSION"; then
    echo "Tag $VERSION criada e enviada com sucesso."
  else
    echo "Erro ao enviar a tag para o repositório remoto."
    exit 1
  fi
else
  echo "Erro ao criar a tag."
  exit 1
fi