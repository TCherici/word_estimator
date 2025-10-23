@echo off
REM Setup script for Windows dependencies
REM This script downloads and installs Tesseract OCR and Poppler for the Word Estimator application

echo ========================================
echo Word Estimator - Windows Setup
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo Warning: Not running as administrator. Some operations may fail.
    echo Please right-click and select "Run as administrator" if installation fails.
    pause
)

echo.
echo This script will download and install required dependencies:
echo - Tesseract OCR (for text extraction from images)
echo - Poppler (for PDF processing)
echo.
pause

REM Create temp directory
set TEMP_DIR=%TEMP%\word_estimator_setup
mkdir "%TEMP_DIR%" 2>nul

REM Download Tesseract
echo.
echo ========================================
echo Downloading Tesseract OCR...
echo ========================================
set TESSERACT_URL=https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe
set TESSERACT_INSTALLER=%TEMP_DIR%\tesseract-setup.exe

powershell -Command "& {Invoke-WebRequest -Uri '%TESSERACT_URL%' -OutFile '%TESSERACT_INSTALLER%'}"

if exist "%TESSERACT_INSTALLER%" (
    echo Download complete!
    echo Installing Tesseract OCR...
    echo Please follow the installer prompts.
    start /wait "" "%TESSERACT_INSTALLER%"
) else (
    echo Failed to download Tesseract.
    echo Please download manually from: https://github.com/UB-Mannheim/tesseract/wiki
)

REM Download Poppler
echo.
echo ========================================
echo Downloading Poppler...
echo ========================================
set POPPLER_URL=https://github.com/oschwartz10612/poppler-windows/releases/download/v24.08.0-0/Release-24.08.0-0.zip
set POPPLER_ZIP=%TEMP_DIR%\poppler.zip
set POPPLER_DIR=%ProgramFiles%\poppler

powershell -Command "& {Invoke-WebRequest -Uri '%POPPLER_URL%' -OutFile '%POPPLER_ZIP%'}"

if exist "%POPPLER_ZIP%" (
    echo Download complete!
    echo Extracting Poppler...
    powershell -Command "& {Expand-Archive -Path '%POPPLER_ZIP%' -DestinationPath '%POPPLER_DIR%' -Force}"
    echo Poppler installed to: %POPPLER_DIR%
) else (
    echo Failed to download Poppler.
    echo Please download manually from: https://github.com/oschwartz10612/poppler-windows/releases
)

REM Add to PATH
echo.
echo ========================================
echo Adding to system PATH...
echo ========================================

REM Add Tesseract to PATH
set TESSERACT_PATH=C:\Program Files\Tesseract-OCR
powershell -Command "& {[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%TESSERACT_PATH%', 'Machine')}"

REM Add Poppler to PATH
set POPPLER_BIN=%POPPLER_DIR%\poppler-24.08.0\Library\bin
powershell -Command "& {[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%POPPLER_BIN%', 'Machine')}"

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Tesseract and Poppler have been installed.
echo You may need to restart your computer for PATH changes to take effect.
echo.
echo After restarting, you can run word_estimator.exe
echo.
pause
