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

@REM Miniconda download URL
set MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
set MINICONDA_INSTALLER=%~dp0MinicondaInstaller.exe

@REM Define paths: Git to be installed in lib folder
set LIB_DIR=%~dp0lib

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

@REM Check if Conda is installed, if not, download and install Miniconda
echo --------------------------------------------------
echo Checking for Conda installation...
echo --------------------------------------------------
conda --version
if %ERRORLEVEL% neq 0 (
    echo Conda is not installed. Downloading Miniconda...
    
    if not exist "%CURL_CMD%" (
        echo [ERROR] %CURL_CMD% not found. Please ensure curl is installed.
        pause & exit /b 1
    )

    echo Downloading Miniconda installer...
    curl -L %MINICONDA_URL% -o %MINICONDA_INSTALLER%
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to download Miniconda installer.
        pause & exit /b 1
    )

    echo Installing Miniconda...
    start /wait "" "%MINICONDA_INSTALLER%" /InstallationType=JustMe /AddToPath=1 /S
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Miniconda installation failed.
        pause & exit /b 1
    )

    echo Miniconda installed successfully. Deleting installer...
    del %MINICONDA_INSTALLER%
    
    echo Verifying Conda installation...
    conda --version
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Conda installation verification failed.
        pause & exit /b 1
    )
) else (
    echo Conda is already installed.
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

@REM Clone the Git repository
echo --------------------------------------------------
echo Cloning the repository...
echo --------------------------------------------------
git clone %REPO_URL%
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

@REM Move into the cloned project folder (assumed to be named AniTTS-Builder-webUI)
cd AniTTS-Builder-webUI

@REM Install dependencies using Conda
echo --------------------------------------------------
echo Installing dependencies with Conda...
echo --------------------------------------------------
conda env create -f AniTTS_Builder_webUI_env.yaml
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

@REM Activate Conda environment
echo --------------------------------------------------
echo Activating Conda environment...
echo --------------------------------------------------
conda activate AniTTS_Builder_webUI_env
if !errorlevel! neq 0 ( pause & exit /b !errorlevel! )

echo --------------------------------------------------
echo Setup complete. You can now run your project.
echo --------------------------------------------------
pause