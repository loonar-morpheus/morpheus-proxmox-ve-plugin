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