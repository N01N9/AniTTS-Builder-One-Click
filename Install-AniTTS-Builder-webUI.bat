chcp 65001 > NUL
@echo off

@REM Error code delayed evaluation settings
setlocal enabledelayedexpansion

@REM PowerShell and curl command paths
set PS_CMD=PowerShell -Version 5.1 -ExecutionPolicy Bypass
set CURL_CMD=C:\Windows\System32\curl.exe

@REM GitHub repository and PortableGit URL
set REPO_URL=https://github.com/N01N9/AniTTS-Builder-webUI.git
set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe
set GIT_DST=%~dp0lib\PortableGit-2.44.0-64-bit.7z.exe

@REM Python download URL
set PYTHON_URL=https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip

@REM Define paths: Python and Git to be installed in lib folder
set LIB_DIR=%~dp0lib
set PYTHON_DIR=%LIB_DIR%\python
set VENV_DIR=%~dp0venv

@REM CUDA, cuDNN, FFmpeg 설치 확인
echo --------------------------------------------------
echo Checking if CUDA 12.1 is installed...
echo --------------------------------------------------
nvcc --version | findstr "release 12.1"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] CUDA 12.1 is not installed or not configured correctly.
    pause
    exit /b 1
) else (
    echo CUDA 12.1 is installed.
)

echo --------------------------------------------------
echo Checking if cuDNN 9.x is installed...
echo --------------------------------------------------
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1\include\cudnn_version.h" (
    findstr "CUDNN_MAJOR 9" "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1\include\cudnn_version.h"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] cuDNN 9.x is not installed or the version is incorrect.
        pause
        exit /b 1
    ) else (
        echo cuDNN 9.x is installed.
    )
) else (
    echo [ERROR] cuDNN is not found in the default installation path.
    pause
    exit /b 1
)

echo --------------------------------------------------
echo Checking FFmpeg installation...
echo --------------------------------------------------
ffmpeg -version
if %ERRORLEVEL% neq 0 (
    echo [ERROR] FFmpeg is not installed.
    pause
    exit /b 1
) else (
    echo FFmpeg is installed.
)

@REM Check for Git installation
echo --------------------------------------------------
echo Checking Git Installation...
echo --------------------------------------------------
git --version
if !errorlevel! neq 0 (
    echo Git is not installed, downloading PortableGit...
    echo --------------------------------------------------
    if not exist "%CURL_CMD%" (
        echo [ERROR] %CURL_CMD% not found. Please ensure curl is installed.
        pause & exit /b 1
    )
    
    echo Downloading PortableGit...
    echo Executing: curl -L %GIT_URL% -o "%GIT_DST%"
    curl -L %GIT_URL% -o "%GIT_DST%"
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Extracting PortableGit...
    "%GIT_DST%" -y
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Removing the downloaded Git archive...
    del "%GIT_DST%"
    
    echo Setting up PATH for PortableGit...
    set "PATH=%LIB_DIR%\PortableGit\bin;%PATH%"
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Verifying Git Installation...
    git --version
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )
)

@REM Check for Python 3.10 and install if necessary
echo --------------------------------------------------
echo Checking Python 3.10...
echo --------------------------------------------------
if not exist "%PYTHON_DIR%" (
    echo Python 3.10 is not installed. Downloading...
    curl -o python.zip %PYTHON_URL%
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Extracting Python...
    %PS_CMD% Expand-Archive -Path python.zip -DestinationPath "%PYTHON_DIR%"
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Removing python.zip...
    del python.zip

    echo Enabling 'site' module in Python...
    %PS_CMD% "&{(Get-Content '%PYTHON_DIR%\python310._pth') -creplace '#import site', 'import site' | Set-Content '%PYTHON_DIR%\python310._pth' }"
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )
    
    echo Downloading get-pip.py...
    curl -o "%PYTHON_DIR%\get-pip.py" https://bootstrap.pypa.io/get-pip.py
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Installing pip...
    "%PYTHON_DIR%\python.exe" "%PYTHON_DIR%\get-pip.py" --no-warn-script-location
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

    echo Installing virtualenv...
    "%PYTHON_DIR%\python.exe" -m pip install virtualenv --no-warn-script-location
    if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )
)

@REM Clone the Git repository
echo --------------------------------------------------
echo Cloning the repository...
echo --------------------------------------------------
git clone %REPO_URL%
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

@REM Move into the cloned project folder (assumed to be named AniTTS-Builder-webUI)
cd AniTTS-Builder-webUI

@REM Create virtual environment inside the cloned project folder
echo --------------------------------------------------
echo Creating virtual environment inside the project folder...
echo --------------------------------------------------
set VENV_DIR=%CD%\venv
"%PYTHON_DIR%\python.exe" -m virtualenv --copies "%VENV_DIR%"
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

@REM Activate virtual environment and install packages
echo --------------------------------------------------
echo Activating virtual environment...
echo --------------------------------------------------
call "%VENV_DIR%\Scripts\activate.bat"
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

@REM Install dependencies
echo --------------------------------------------------
echo Installing dependencies...
echo --------------------------------------------------
pip install pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )
pip install -r requirements.txt --no-deps
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

echo --------------------------------------------------
echo Setup complete. You can now run your project.
echo --------------------------------------------------
pause
