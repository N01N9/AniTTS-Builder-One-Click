@echo off
chcp 65001 > NUL

REM Enable delayed variable expansion for error handling
setlocal enabledelayedexpansion

REM PowerShell and curl command configurations
set PS_CMD=PowerShell -Version 5.1 -ExecutionPolicy Bypass
set CURL_CMD=C:\Windows\System32\curl.exe

REM PortableGit download URL and destination path
set GIT_DL_URL=https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe
set GIT_DL_DST=%~dp0lib\PortableGit-2.44.0-64-bit.7z.exe

REM Miniconda download URL and destination path
set CONDA_DL_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
set CONDA_DL_DST=%~dp0lib\Miniconda3-latest-Windows-x86_64.exe

REM Repository URL to clone
set REPO_URL=https://github.com/N01N9/AniTTS-Builder-webUI.git

REM Navigate to the batch file's directory
pushd %~dp0

REM Create the lib folder if it doesn't exist
if not exist lib\ ( mkdir lib )

echo --------------------------------------------------
echo PS_CMD: %PS_CMD%
echo CURL_CMD: %CURL_CMD%
echo GIT_DL_URL: %GIT_DL_URL%
echo GIT_DL_DST: %GIT_DL_DST%
echo REPO_URL: %REPO_URL%
echo --------------------------------------------------

@REM Checking CUDA, cuDNN, FFmpeg is installed...
echo --------------------------------------------------
echo Checking if CUDA 12.1 is installed...
echo --------------------------------------------------
where nvcc >nul 2>&1
( if %ERRORLEVEL% neq 0 ( echo CUDA is not installed or not in the system PATH. & echo Please install CUDA 12.1 and ensure it is added to the PATH. & pause & exit /b 1 ) )
nvcc --version | findstr "release 12.1" >nul 2>&1
( if %ERRORLEVEL% neq 0 ( echo CUDA version is not 12.1. & echo Please install or configure CUDA 12.1 correctly and try again. & pause & exit /b 1 ) )
echo CUDA 12.1 is installed.

echo --------------------------------------------------
echo Checking if cuDNN 9.x is installed...
echo --------------------------------------------------
where cudnn_version.h >nul 2>&1
( if %ERRORLEVEL% neq 0 ( echo cuDNN is not installed or not found. & echo Please ensure cuDNN is installed in the correct location. & pause & exit /b 1 ) )
findstr "CUDNN_MAJOR 9" "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1\include\cudnn_version.h" >nul 2>&1
( if %ERRORLEVEL% neq 0 ( echo cuDNN 9.x is not installed or the version is incorrect. & echo Please install the correct version of cuDNN 9.x and try again. & pause & exit /b 1 ) )
echo cuDNN 9.x is installed.

echo --------------------------------------------------
echo Checking FFmpeg installation...
echo --------------------------------------------------
where ffmpeg >nul 2>&1
( if %ERRORLEVEL% neq 0 ( echo FFmpeg is not installed or not in the system PATH. & echo Please install FFmpeg and ensure it is added to the PATH. & pause & exit /b 1 ) )
echo FFmpeg is installed.

echo --------------------------------------------------
echo All necessary tools are installed.
pause

echo --------------------------------------------------
echo Checking Git Installation...
echo --------------------------------------------------
where git >nul 2>&1
if !errorlevel! neq 0 (
    echo Git is not installed. Downloading PortableGit...
    curl -L %GIT_DL_URL% -o "%GIT_DL_DST%"
    if !errorlevel! neq 0 ( echo Failed to download PortableGit. Exiting... & pause & exit /b 1 )
    
    echo Extracting PortableGit...
    "%GIT_DL_DST%" -y
    if !errorlevel! neq 0 ( echo Failed to extract PortableGit. Exiting... & pause & exit /b 1 )
    
    echo Removing PortableGit archive...
    del "%GIT_DL_DST%"
    
    echo Adding Git to PATH...
    set "PATH=%~dp0lib\PortableGit\bin;%PATH%"
    if !errorlevel! neq 0 ( echo Failed to set PATH. Exiting... & pause & exit /b 1 )
    
    where git
    if !errorlevel! neq 0 ( echo Git installation failed. Exiting... & pause & exit /b 1 )
)

echo --------------------------------------------------
echo Checking Conda Installation...
echo --------------------------------------------------
where conda >nul 2>&1

if !errorlevel! neq 0 (
    echo Conda is not installed. Downloading Miniconda...
    curl -L %CONDA_DL_URL% -o "%CONDA_DL_DST%"
    if !errorlevel! neq 0 ( echo Failed to download Miniconda. Exiting... & pause & exit /b 1 )
    
    echo Installing Miniconda...
    "%CONDA_DL_DST%" /InstallationType=JustMe /RegisterPython=0 /S /D=%~dp0lib\Miniconda3
    if !errorlevel! neq 0 ( echo Failed to install Miniconda. Exiting... & pause & exit /b 1 )
    
    echo Removing Miniconda installer...
    del "%CONDA_DL_DST%"
    
    echo Adding Conda to PATH...
    set "PATH=%~dp0lib\Miniconda3\Scripts;%PATH%"
    where conda
    if !errorlevel! neq 0 ( echo Conda installation failed. Exiting... & pause & exit /b 1 )
)

echo --------------------------------------------------
echo Cloning repository...
echo --------------------------------------------------
git clone %REPO_URL%
if !errorlevel! neq 0 ( echo Failed to clone repository. Exiting... & pause & exit /b 1 )

REM Create Conda environment from the YAML file in the cloned repository
set REPO_DIR=AniTTS-Builder-webUI
if exist "%REPO_DIR%\AniTTS-Builder-env.yaml" (
    echo --------------------------------------------------
    echo Found AniTTS-Builder-env.yaml. Creating Conda environment...
    echo --------------------------------------------------
    conda env create -f "%REPO_DIR%\AniTTS-Builder-env.yaml"
    if !errorlevel! neq 0 ( echo Failed to create Conda environment. Exiting... & pause & exit /b 1 )
) else (
    echo --------------------------------------------------
    echo AniTTS-Builder-env.yaml not found. Skipping Conda environment creation...
    echo --------------------------------------------------
)

pause
popd
popd
endlocal
