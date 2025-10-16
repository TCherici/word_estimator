# PDF Keyword Value Estimator

A simple desktop application that counts keyword occurrences in PDF files and calculates their total value based on assigned integer values.

## Features

- Browse and select PDF files
- Add multiple keywords with custom integer values
- Case-insensitive keyword matching
- Calculate total sum of all keyword occurrences
- **Automatic OCR support** for image-based/scanned PDFs
- Progress indicator for OCR processing
- Clean, user-friendly GUI interface
- Cross-platform support (Windows, macOS, Linux)

## Installation

### For Users (Standalone Executable)

1. **Install Tesseract OCR** (required for image-based PDFs):

   **Windows:**
   - Download the installer from: https://github.com/UB-Mannheim/tesseract/wiki
   - Run the installer and follow the prompts
   - Note the installation path (typically `C:\Program Files\Tesseract-OCR`)
   - Add Tesseract to your system PATH or the application will prompt for the location

   **macOS:**
   ```bash
   brew install tesseract
   ```

   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt-get update
   sudo apt-get install tesseract-ocr
   ```

   **Linux (Fedora/RHEL):**
   ```bash
   sudo dnf install tesseract
   ```

2. **Install Poppler** (required for OCR processing):

   **Windows:**
   - Download from: https://github.com/oschwartz10612/poppler-windows/releases
   - Extract the ZIP file
   - Add the `bin` folder to your system PATH

   **macOS:**
   ```bash
   brew install poppler
   ```

   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt-get install poppler-utils
   ```

   **Linux (Fedora/RHEL):**
   ```bash
   sudo dnf install poppler-utils
   ```

3. Download the executable file for your operating system:
   - Windows: `word_estimator.exe`
   - macOS: `word_estimator.app`
   - Linux: `word_estimator`

4. Double-click to run

### For Developers

#### Prerequisites

- Python 3.8 or higher
- uv (recommended) or pip (Python package installer)
- Tesseract OCR (see installation instructions above)
- Poppler (see installation instructions above)

#### Setup

1. Clone or download this repository

2. Navigate to the project directory:
   ```bash
   cd word_estimator
   ```

3. Install Tesseract OCR and Poppler (follow instructions in "For Users" section above)

4. Install required Python dependencies:

   **Using uv (recommended):**
   ```bash
   # uv will read dependencies from the inline script metadata in main.py
   uv run main.py
   ```

   **Using traditional pip:**
   ```bash
   pip install -r requirements.txt
   python main.py
   ```

Note: Dependencies are defined inline in `main.py` using PEP 723 script metadata, so `uv` can automatically manage them without a separate requirements file.

## Usage

### Step-by-Step Guide

1. **Select a PDF File**
   - Click the "Browse..." button
   - Navigate to and select your PDF file
   - The filename will be displayed once selected

2. **Enter Keywords and Values**
   - Fill in the table with your keywords and their integer values
   - Keyword: The word or phrase to search for (case-insensitive)
   - Value: An integer number representing the value for each occurrence
   - Use "Add Row" to add more keyword entries
   - Use "Remove Selected Row" to delete a specific entry
   - Use "Clear All" to reset the entire table

3. **Calculate**
   - Click the "Calculate Total" button
   - For text-based PDFs: Results display instantly
   - For image-based PDFs: You'll be prompted to use OCR
     - OCR processing shows a progress dialog
     - Processing time depends on PDF size and number of pages
   - Results will be displayed showing:
     - Each keyword with its occurrence count
     - Individual subtotals (count × value)
     - Grand total sum

### Example

If your PDF contains:
- "project" appears 5 times
- "meeting" appears 3 times
- "deadline" appears 2 times

And you assign values:
- project = 10
- meeting = 5
- deadline = 15

The result will be:
- project: 5 × 10 = 50
- meeting: 3 × 5 = 15
- deadline: 2 × 15 = 30
- **Grand Total: 95**

## Building an Executable

**IMPORTANT**: To avoid including unnecessary dependencies, use a clean virtual environment.

### Recommended Method: Using uv (All Platforms)

This project uses PEP 723 inline script metadata for dependency management with uv.

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Or visit: https://docs.astral.sh/uv/getting-started/installation/

2. **Run the build script**:
   ```bash
   ./build_with_uv.sh
   ```

This script will:
1. Create a clean virtual environment using uv
2. Install only required dependencies (defined inline in main.py)
3. Build the executable using PyInstaller
4. Clean up the virtual environment

The executable will be in the `dist/` folder.

### Alternative Method: Traditional pip

If you prefer not to use uv, you can use the traditional pip-based build:

```bash
./build_executable.sh
```

### Manual Method

If you prefer to build manually:

1. Create a clean virtual environment:
   ```bash
   python3 -m venv venv_build
   source venv_build/bin/activate  # On Windows: venv_build\Scripts\activate
   ```

2. Install only required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Build with PyInstaller:
   ```bash
   pyinstaller --clean word_estimator.spec
   ```

4. Deactivate and remove virtual environment:
   ```bash
   deactivate
   rm -rf venv_build
   ```

### Platform-Specific Notes

- **Windows**: The executable will be `dist/word_estimator.exe`
- **macOS**: The app bundle will be `dist/word_estimator.app`
- **Linux**: The executable will be `dist/word_estimator`

**Why use a clean virtual environment?**
Building from your main Python environment may include unnecessary packages (pandas, torch, scikit-learn, etc.), making the executable unnecessarily large (500MB+). A clean environment keeps it small (~100MB).

## Technical Details

### Dependencies

- **PyQt5**: GUI framework for the desktop application
- **PyMuPDF (fitz)**: Fast PDF text extraction for text-based PDFs
- **pytesseract**: Python wrapper for Tesseract OCR
- **pdf2image**: Converts PDF pages to images for OCR processing
- **Pillow**: Image processing library
- **PyInstaller**: Tool for creating standalone executables

### Text Extraction Methods

The application uses a smart two-tier approach:

1. **Fast Text Extraction** (default):
   - Uses PyMuPDF for instant text extraction
   - Works with text-based PDFs
   - No OCR overhead

2. **OCR Fallback** (automatic):
   - Triggers when no text is detected
   - Converts PDF pages to images (300 DPI)
   - Uses Tesseract OCR to extract text from images
   - Shows progress dialog during processing
   - Processing time: ~5-30 seconds per page depending on complexity

### Keyword Matching

- Matching is case-insensitive ("Project" and "project" are treated the same)
- Uses regex-based word matching
- Searches entire PDF content across all pages

## Troubleshooting

### OCR Not Working

**"TesseractNotFoundError":**
- Tesseract OCR is not installed or not in your system PATH
- **Windows**: Add Tesseract installation directory to PATH, or set it in the code
- **macOS/Linux**: Reinstall using package manager (brew/apt/dnf)
- Verify installation: Run `tesseract --version` in terminal

**"Unable to load pdf2image":**
- Poppler is not installed or not in your system PATH
- Follow the Poppler installation instructions for your OS above
- **Windows**: Ensure poppler's `bin` folder is in your system PATH

### OCR Taking Too Long

- OCR processing is CPU-intensive and depends on:
  - Number of pages in PDF
  - Image resolution (300 DPI is used for quality)
  - CPU performance
- You can cancel OCR processing using the Cancel button in the progress dialog
- For very large PDFs (50+ pages), consider splitting into smaller files

### OCR Results Inaccurate

- Ensure the PDF images have good quality and contrast
- Low-quality scans may produce poor OCR results
- Handwritten text is not well-supported by Tesseract
- Consider re-scanning documents at higher DPI if possible

### Application Won't Start

- Ensure you have Python 3.8 or higher installed
- Try reinstalling dependencies: `pip install -r requirements.txt --force-reinstall`
- Check that all required packages are installed successfully
- Verify Tesseract and Poppler are installed correctly

### PDF Loading Issues

- Ensure the PDF file is not corrupted
- Try opening the PDF in a PDF reader first to verify it works
- Check that you have read permissions for the file
- Some password-protected PDFs may not work

## License

This project is provided as-is for personal and commercial use.

## Support

For issues or questions, please refer to the documentation or contact the developer.
