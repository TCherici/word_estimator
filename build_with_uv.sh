#!/bin/bash
# Build script for word_estimator executable using uv
# This script uses uv for dependency management and builds executables for both Linux and Windows

set -e  # Exit on error

# Check if Wine is installed for Windows builds
check_wine() {
    if command -v wine &> /dev/null; then
        echo "Wine detected: $(wine --version)"
        return 0
    else
        echo "Wine not detected. Windows build will be skipped."
        echo "To build for Windows, install Wine: sudo apt-get install wine wine64"
        return 1
    fi
}

WINE_AVAILABLE=false
if check_wine; then
    WINE_AVAILABLE=true
fi

echo ""
echo "=== Building Linux executable ==="
echo ""

echo "Creating clean virtual environment with uv..."
uv venv venv_build

echo "Activating virtual environment..."
source venv_build/bin/activate

echo "Installing dependencies using uv..."
uv pip install "PyQt5>=5.15.10" "PyMuPDF>=1.23.8" "pytesseract>=0.3.10" "pdf2image>=1.16.3" "Pillow>=10.2.0" "openpyxl>=3.1.2" "pyinstaller>=6.3.0"

echo "Building Linux executable with PyInstaller..."
pyinstaller --clean word_estimator.spec

echo "Linux build complete!"
echo ""

# Build Windows executable if Wine is available
if [ "$WINE_AVAILABLE" = true ]; then
    echo ""
    echo "=== Building Windows executable ==="
    echo ""

    # Check if Python is installed in Wine
    if ! wine python --version &> /dev/null; then
        echo "Python not found in Wine environment."
        echo "Please install Python in Wine first:"
        echo "  1. Download Python installer from https://www.python.org/downloads/windows/"
        echo "  2. Run: wine python-3.x.x.exe"
        echo ""
        echo "Skipping Windows build..."
    else
        echo "Creating Windows virtual environment..."
        wine python -m venv venv_build_windows

        echo "Activating Windows virtual environment..."
        # Wine venv activation
        WINE_PYTHON="wine venv_build_windows/Scripts/python.exe"

        echo "Installing dependencies in Windows environment..."
        $WINE_PYTHON -m pip install --upgrade pip
        $WINE_PYTHON -m pip install "PyQt5>=5.15.10" "PyMuPDF>=1.23.8" "pytesseract>=0.3.10" "pdf2image>=1.16.3" "Pillow>=10.2.0" "openpyxl>=3.1.2" "pyinstaller>=6.3.0"

        echo "Building Windows executable with PyInstaller..."
        $WINE_PYTHON -m PyInstaller --clean word_estimator.spec

        echo "Windows build complete!"
        echo ""

        echo "Cleaning up Windows virtual environment..."
        rm -rf venv_build_windows
    fi
else
    echo ""
    echo "Skipping Windows build (Wine not available)"
    echo ""
fi

echo ""
echo "=== Build Summary ==="
if [ -f "dist/word_estimator" ]; then
    echo "✓ Linux executable: dist/word_estimator"
else
    echo "✗ Linux build failed"
fi

if [ -f "dist/word_estimator.exe" ]; then
    echo "✓ Windows executable: dist/word_estimator.exe"
else
    echo "✗ Windows build skipped or failed"
fi

echo ""
echo "To test the Linux executable:"
echo "  ./dist/word_estimator"
echo ""

echo "Cleaning up Linux virtual environment..."
deactivate
rm -rf venv_build

echo "Done!"
