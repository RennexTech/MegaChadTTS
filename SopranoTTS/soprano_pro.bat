@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "APP=Soprano Studio Pro"
set "SCRIPT=soprano_studio.py"
set "PY=venv\Scripts\python.exe"
set "PYW=venv\Scripts\pythonw.exe"
set "MARK=venv\.setup_ok"
set "PIP_PKGS=soprano-tts soundfile numpy pygame"
set "CHECK=from soprano import SopranoTTS; import soundfile, numpy, pygame"

REM ============================================================
REM  QUIET MODE  (called by soprano_pro.vbs, no window at all)
REM  If setup was already finished once, just start the app.
REM  If not, reopen this bat in a visible window to do the setup.
REM ============================================================
if /i "%~1"=="quiet" (
    if exist "%MARK%" (
        if exist "%PYW%" (
            if exist "%SCRIPT%" (
                start "" "%PYW%" "%SCRIPT%"
                exit /b 0
            )
        )
    )
    start "" "%~f0"
    exit /b 0
)

echo ============================================
echo   %APP% - Full Setup ^& Launch
echo ============================================
echo.

REM ---------- 1. Check for the app file ----------
if not exist "%SCRIPT%" (
    echo [X] %SCRIPT% is not in this folder.
    echo     Put it next to this bat file and run again.
    pause & exit /b 1
)
echo [*] %SCRIPT% found.

REM ---------- 2. Check for Python ----------
where py >nul 2>nul
if errorlevel 1 (
    where python >nul 2>nul
    if errorlevel 1 (
        echo [X] Python not found. Install Python 3.12 from https://python.org
        echo     Make sure to check "Add Python to PATH" during installation.
        pause & exit /b 1
    )
    set "PYTHON_CMD=python"
) else (
    set "PYTHON_CMD=py -3.12"
    !PYTHON_CMD! -c "import sys" >nul 2>&1
    if errorlevel 1 set "PYTHON_CMD=py -3"
)
echo [*] Python found: %PYTHON_CMD%

REM ---------- 3. Create venv if missing ----------
if not exist "%PY%" (
    echo [*] Creating virtual environment...
    %PYTHON_CMD% -m venv venv
    if not exist "%PY%" (
        echo [X] Could not create the virtual environment.
        pause & exit /b 1
    )
) else (
    echo [*] Virtual environment already exists.
)

REM ---------- 4. Install/repair dependencies ----------
echo [*] Checking dependencies...
"%PY%" -c "%CHECK%" >nul 2>&1
if errorlevel 1 (
    echo [*] Installing dependencies, this can take a few minutes...
    "%PY%" -m pip install --upgrade pip setuptools wheel
    "%PY%" -m pip install %PIP_PKGS%
    if errorlevel 1 (
        echo [X] Dependency install failed. Scroll up for details.
        pause & exit /b 1
    )
    "%PY%" -c "%CHECK%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Packages installed but the import still fails.
        echo     Run this to see the real error:
        echo     "%PY%" -c "%CHECK%"
        pause & exit /b 1
    )
    echo [*] Dependencies installed successfully.
) else (
    echo [*] All dependencies present.
)

REM Setup is done: from now on soprano_pro.vbs can start the app silently
echo ok> "%MARK%"

REM ---------- 5. Check for ffmpeg (optional MP3 support) ----------
where ffmpeg >nul 2>nul
if errorlevel 1 (
    if exist "ffmpeg.exe" (echo [*] Using local ffmpeg.exe) else (echo [!] No ffmpeg - WAV only, MP3 disabled)
) else (
    echo [*] ffmpeg found on PATH
)

REM ---------- 6. Launch ----------
echo.
echo [*] Launching %APP%...
echo     (First launch: the model downloads from Hugging Face on first launch)
echo     From now on, just double-click soprano_pro.vbs - no window needed.
echo.
"%PY%" "%SCRIPT%"
if errorlevel 1 (
    echo.
    echo [X] The app exited with an error. Scroll up.
    pause
)
endlocal
