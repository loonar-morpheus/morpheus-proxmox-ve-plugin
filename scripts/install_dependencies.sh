#!/bin/bash

# Check if act is installed
if ! command -v act &> /dev/null
then
    echo "act could not be found. Installing..."
    # Install act
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
else
    echo "act is already installed."
fi

# Check if Gradle is installed
if ! command -v gradle &> /dev/null
then
    echo "Gradle could not be found. Installing..."
    # Install Gradle
    sudo apt update && sudo apt install -y gradle
else
    echo "Gradle is already installed."
fi

# Check if Python virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Check if pre-commit is installed in the virtual environment
if ! venv/bin/pre-commit --version &> /dev/null
then
    echo "pre-commit could not be found in the virtual environment. Installing..."
    pip install pre-commit
else
    echo "pre-commit is already installed in the virtual environment."
fi

# Install pre-commit hooks
venv/bin/pre-commit install

# Deactivate the virtual environment
deactivate

# Check if Node.js is installed
if ! command -v npm &> /dev/null
then
    echo "Node.js could not be found. Installing..."
    # Install Node.js
    sudo apt update && sudo apt install -y nodejs npm
else
    echo "Node.js is already installed."
fi

# Ensure package.json exists before running husky-init
if [ ! -f "package.json" ]; then
  echo "package.json not found. Creating one..."
  npm init -y
fi

# Ensure the script runs from the Git root
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT" || exit

# Install Husky
if [ ! -d ".husky" ]; then
  echo "Husky directory not found. Initializing Husky..."
  npx husky-init && npm install
fi

# Configure Husky post-commit hook
cat <<EOT > "$GIT_ROOT/.husky/post-commit"
#!/bin/sh
. "\$(dirname "\$0")/_/husky.sh"

# Run git-release.sh
bash git-release.sh
EOT

chmod +x "$GIT_ROOT/.husky/post-commit"