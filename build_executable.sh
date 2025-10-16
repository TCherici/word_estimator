#!/bin/bash
# Build script for word_estimator executable
# This script creates a clean virtual environment and builds the executable

set -e  # Exit on error

echo "Creating clean virtual environment..."
python3 -m venv venv_build

echo "Activating virtual environment..."
source venv_build/bin/activate

echo "Installing only required dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Building executable with PyInstaller..."
pyinstaller --clean word_estimator.spec

echo "Build complete! Executable is in dist/word_estimator"
echo ""
echo "To test the executable:"
echo "  ./dist/word_estimator"
echo ""
echo "Cleaning up virtual environment..."
deactivate
rm -rf venv_build

echo "Done!"
