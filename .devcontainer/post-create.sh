#!/bin/bash

echo "🚀 Setting Development Environment..."

# Atualiza o sistema
sudo apt-get update

# Instala dependências adicionais
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    ssh \
    vim \
    nano \
    tree \
    jq

# Instala Gradle manualmente
echo "📦 Installing Gradle..."
GRADLE_VERSION=8.4
wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
sudo unzip -q gradle-${GRADLE_VERSION}-bin.zip -d /opt/
sudo ln -sf /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
rm gradle-${GRADLE_VERSION}-bin.zip

# Configura permissões do Docker
sudo usermod -aG docker vscode

# Configura Git
echo "📝 Configurando Git..."
git config --global init.defaultBranch main
git config --global pull.rebase false

# Configura permissões do wrapper do Gradle
if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    echo "🔧 Wrapper do Gradle configurado"
fi

# Verifica as versões instaladas
echo "✅ Verificando versões instaladas:"
java -version 2>&1 | head -n 1
gradle --version | head -n 3 | tail -n 1
docker --version 2>/dev/null || echo "Docker: Não disponível"
gh --version 2>/dev/null | head -n 1 || echo "GitHub CLI: Instalando..."

echo "🎉 Configuração do ambiente concluída!"
echo ""
echo "📋 Comandos úteis:"
echo "  ./gradlew clean build    - Compila o projeto"
echo "  ./gradlew test          - Executa os testes"
echo "  docker ps               - Lista containers Docker"
echo "  gh auth login           - Autentica no GitHub"
echo ""
