#!/bin/bash
# Script to install Python in Wine for cross-compiling Windows executables

set -e

echo "Setting up Python in Wine environment..."
echo ""

# Check if Wine is installed
if ! command -v wine &> /dev/null; then
    echo "Error: Wine is not installed."
    echo "Install it with: sudo apt-get install wine wine64"
    exit 1
fi

echo "Wine version: $(wine --version)"
echo ""

# Configure Wine to report as Windows 10 (required for Python 3.11+)
echo "Configuring Wine to emulate Windows 10..."
WINEARCH=win64 winecfg /v win10 2>&1 | grep -v "err:system\|err:explorer" || true
sleep 2

# Use Python 3.9 instead (supports Windows 7+, more compatible with Wine)
PYTHON_VERSION="3.9.13"
PYTHON_INSTALLER="python-${PYTHON_VERSION}-amd64.exe"

# Check if Python installer exists
if [ ! -f "$PYTHON_INSTALLER" ]; then
    echo "Downloading Python ${PYTHON_VERSION} installer (Wine-compatible version)..."
    wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_INSTALLER}"
fi

echo ""
echo "Installing Python ${PYTHON_VERSION} in Wine (this may take a few minutes)..."
echo "Note: Display errors from Wine can be safely ignored."
echo ""

# Install Python silently with all features
# /quiet = silent install, InstallAllUsers=0 = current user only, PrependPath=1 = add to PATH
WINEDEBUG=-all wine "$PYTHON_INSTALLER" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 &
INSTALL_PID=$!

# Wait for installation with progress indicator
echo -n "Installing"
for i in {1..30}; do
    if ! ps -p $INSTALL_PID > /dev/null 2>&1; then
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Wait a bit more for wine processes to finish
sleep 3

echo ""
echo "Verifying Python installation in Wine..."

# Try multiple possible Python paths
PYTHON_PATHS=(
    "$HOME/.wine/drive_c/users/$USER/AppData/Local/Programs/Python/Python39/python.exe"
    "$HOME/.wine/drive_c/Program Files/Python39/python.exe"
    "$HOME/.wine/drive_c/Python39/python.exe"
)

WINE_PYTHON_PATH=""
for path in "${PYTHON_PATHS[@]}"; do
    if [ -f "$path" ]; then
        echo "Found Python at: $path"
        if WINEDEBUG=-all wine "$path" --version 2>&1 | grep -q "Python"; then
            WINE_PYTHON_PATH="$path"
            break
        fi
    fi
done

if [ -n "$WINE_PYTHON_PATH" ]; then
    echo "✓ Python successfully installed in Wine!"
    WINEDEBUG=-all wine "$WINE_PYTHON_PATH" --version 2>&1 | grep "Python"
    echo ""
    echo "Python location: $WINE_PYTHON_PATH"
    echo ""

    # Create a symlink for easy access
    mkdir -p "$HOME/.local/bin"
    echo "WINEDEBUG=-all wine \"$WINE_PYTHON_PATH\" \"\$@\"" > "$HOME/.local/bin/wine-python"
    chmod +x "$HOME/.local/bin/wine-python"

    echo "Created wine-python wrapper at: $HOME/.local/bin/wine-python"
    echo ""
    echo "You can now run ./build_with_uv.sh to build both Linux and Windows executables."
else
    echo "✗ Python installation verification failed."
    echo ""
    echo "Searched in the following locations:"
    for path in "${PYTHON_PATHS[@]}"; do
        echo "  - $path"
    done
    echo ""
    echo "Please check the Wine installation log at:"
    echo "  ~/.wine/drive_c/users/$USER/Temp/Python*.log"
    exit 1
fi
