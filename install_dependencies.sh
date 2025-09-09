#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Move to git root
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT" || exit 1

# Clean up existing configurations
if [ -d ".husky" ]; then
  echo "Removing existing Husky configuration..."
  rm -rf .husky || { echo "Failed to remove Husky configuration"; exit 1; }
fi

if [ -d "venv" ]; then
  echo "Removing existing Python virtual environment..."
  rm -rf venv || { echo "Failed to remove virtual environment"; exit 1; }
fi

if [ -f ".git/hooks/pre-commit" ]; then
  echo "Removing existing pre-commit hook..."
  rm -f .git/hooks/pre-commit || { echo "Failed to remove pre-commit hook"; exit 1; }
fi

# Show and unset core.hooksPath if set
if git config --show-origin --get-all core.hooksPath &> /dev/null; then
  echo "core.hooksPath is set at the following locations:"
  git config --show-origin --get-all core.hooksPath || true
  echo "Attempting to unset core.hooksPath at local and global scopes..."
  git config --local --unset-all core.hooksPath 2>/dev/null || true
  git config --global --unset-all core.hooksPath 2>/dev/null || true
  echo "After unsetting, current values (if any):"
  git config --show-origin --get-all core.hooksPath || true
fi

# Ensure pipx is installed
if ! command -v pipx &> /dev/null; then
  echo "Installing pipx..."
  python3 -m ensurepip --upgrade || { echo "Failed to ensure pip is available"; exit 1; }
  python3 -m pip install --user pipx || { echo "Failed to install pipx"; exit 1; }
  python3 -m pipx ensurepath || { echo "Failed to configure pipx path"; exit 1; }
  export PATH="$HOME/.local/bin:$PATH"
fi

# Ensure pre-commit is installed via pipx (preferred in externally-managed envs)
if ! pipx list | grep -q "pre-commit"; then
  echo "Installing pre-commit using pipx..."
  pipx install pre-commit || { echo "Failed to install pre-commit with pipx"; exit 1; }
else
  echo "pre-commit is already installed via pipx."
fi

# Diagnostic: which pre-commit and its version
echo "which pre-commit: $(command -v pre-commit || true)"
pre_commit_version_output=$(pre-commit --version 2>&1 || true)
echo "pre-commit --version output: $pre_commit_version_output"

# Try to install pre-commit hooks the normal way. If it fails, create a fallback hook.
if [ -f ".pre-commit-config.yaml" ]; then
  echo "Installing pre-commit hooks via 'pre-commit install'..."
  if pre-commit install --install-hooks; then
    echo "pre-commit hooks installed successfully."
  else
    echo "pre-commit install failed; creating fallback .git/hooks/pre-commit to run pre-commit manually."
    cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Fallback pre-commit hook created by install_dependencies.sh
exec pre-commit run --all-files
HOOK
    chmod +x .git/hooks/pre-commit
    echo "Fallback pre-commit hook created at .git/hooks/pre-commit"
  fi
else
  echo "No .pre-commit-config.yaml found. Skipping pre-commit hook installation."
fi

# Ensure Husky is installed (initialize if missing)
if [ ! -d ".husky" ]; then
  echo "Installing Husky..."
  # husky-init creates .husky and a sample pre-commit; use --no-verify to avoid running hooks now
  npx husky-init --no-verify >/dev/null 2>&1 || true
  npm install --no-audit --no-fund >/dev/null 2>&1 || true
fi

# Create Husky post-commit hook file (doesn't run it now)
cat > .husky/post-commit <<'EOT'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "Post-commit hook executed"

# Change directory to ./scripts in the repository root and run git-release.sh
cd "$(git rev-parse --show-toplevel)/scripts" || exit 1
bash git-release.sh
EOT
chmod +x .husky/post-commit

# Create Husky pre-commit hook that delegates to pre-commit (if not present)
if [ ! -f .husky/pre-commit ]; then
  cat > .husky/pre-commit <<'EOT'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Delegate to pre-commit
exec pre-commit run --all-files
EOT
  chmod +x .husky/pre-commit
fi

# Install Node.js dependencies for scripts if present.
# Some subfolders may include a "prepare" script that runs `husky install` which
# expects a .git directory in the same folder. Disable Husky during this npm
# install so the prepare hook doesn't run inside the subdirectory and fail.
if [ -f "scripts/package.json" ]; then
  echo "Installing Node.js dependencies in scripts/... (disabling Husky during install)"
  # Export HUSKY=0 for current command only to skip husky's prepare script in subdir
  HUSKY=0 npm install --prefix scripts || { echo "Failed to install Node.js dependencies"; exit 1; }
fi

echo "Done. Hooks configured. Test by running: git add . && git commit -m 'test'"