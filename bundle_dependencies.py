#!/usr/bin/env python3
"""
Script to download and prepare Tesseract and Poppler for bundling with PyInstaller.
Run this before building the executable.
"""

import os
import sys
import zipfile
import tarfile
from pathlib import Path
import urllib.request
import shutil

def download_file(url, dest_path):
    """Download a file with progress."""
    print(f"Downloading {url}...")
    try:
        urllib.request.urlretrieve(url, dest_path)
        print(f"✓ Downloaded to {dest_path}")
        return True
    except Exception as e:
        print(f"✗ Failed to download: {e}")
        return False

def extract_zip(zip_path, extract_to):
    """Extract a ZIP file."""
    print(f"Extracting {zip_path}...")
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print(f"✓ Extracted to {extract_to}")
        return True
    except Exception as e:
        print(f"✗ Failed to extract: {e}")
        return False

def setup_windows_dependencies():
    """Download and setup Tesseract and Poppler for Windows."""
    deps_dir = Path("windows_deps")
    deps_dir.mkdir(exist_ok=True)

    print("\n=== Setting up Windows dependencies ===\n")

    # Tesseract for Windows
    tesseract_url = "https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe"
    # Note: This is an installer, we need the portable version instead
    tesseract_portable_url = "https://github.com/UB-Mannheim/tesseract/releases/download/v5.3.3.20231005/tesseract-ocr-w64-setup-5.3.3.20231005.exe"

    # Poppler for Windows
    poppler_url = "https://github.com/oschwartz10612/poppler-windows/releases/download/v24.08.0-0/Release-24.08.0-0.zip"

    # Download Poppler
    poppler_zip = deps_dir / "poppler.zip"
    if not poppler_zip.exists():
        if download_file(poppler_url, poppler_zip):
            extract_zip(poppler_zip, deps_dir / "poppler")
    else:
        print(f"Poppler already downloaded: {poppler_zip}")

    print("\n=== Manual Steps Required ===\n")
    print("Tesseract OCR cannot be automatically downloaded in portable format.")
    print("\nPlease follow these steps:")
    print("1. Download Tesseract portable from:")
    print("   https://github.com/UB-Mannheim/tesseract/releases")
    print("2. Extract to: windows_deps/tesseract/")
    print("3. Ensure the structure is: windows_deps/tesseract/tesseract.exe")
    print("\nOr, download the installer and extract manually using 7-Zip.")

    return deps_dir

def setup_linux_dependencies():
    """Setup instructions for Linux dependencies."""
    print("\n=== Linux dependencies ===\n")
    print("On Linux, dependencies are typically installed system-wide:")
    print("  sudo apt-get install tesseract-ocr poppler-utils")
    print("\nThe Linux build will use system dependencies.")

if __name__ == "__main__":
    platform = sys.platform

    if platform == "win32":
        setup_windows_dependencies()
    elif platform.startswith("linux"):
        setup_linux_dependencies()
    else:
        print(f"Platform {platform} not explicitly supported by this script.")
        print("Please install Tesseract and Poppler manually.")
