@echo off
chcp 65001 > NUL

REM 에러코드를 위한 설정
setlocal enabledelayedexpansion

REM PowerShell 및 curl 명령어 설정
set PS_CMD=PowerShell -Version 5.1 -ExecutionPolicy Bypass
set CURL_CMD=C:\Windows\System32\curl.exe

REM PortableGit URL 및 저장 경로 설정
set GIT_DL_URL=https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe
set GIT_DL_DST=%~dp0lib\PortableGit-2.44.0-64-bit.7z.exe

REM Conda 다운로드 URL 및 저장 경로 설정
set CONDA_DL_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
set CONDA_DL_DST=%~dp0lib\Miniconda3-latest-Windows-x86_64.exe

REM 리포지토리 URL 설정
set REPO_URL=https://github.com/N01N9/AniTTS-Builder-webUI.git

REM 현재 경로를 bat 파일 위치로 이동
pushd %~dp0

REM lib 폴더가 없다면 생성
if not exist lib\ ( mkdir lib )

echo --------------------------------------------------
echo PS_CMD: %PS_CMD%
echo CURL_CMD: %CURL_CMD%
echo GIT_DL_URL: %GIT_DL_URL%
echo GIT_DL_DST: %GIT_DL_DST%
echo REPO_URL: %REPO_URL%
echo --------------------------------------------------

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

REM 클론한 리포지토리 내의 yaml 파일로 conda 환경 생성
set REPO_DIR=AniTTS-Builder-webUI
if exist "%REPO_DIR%\environment.yaml" (
    echo --------------------------------------------------
    echo Found environment.yaml. Creating Conda environment...
    echo --------------------------------------------------
    conda env create -f "%REPO_DIR%\environment.yaml"
    if !errorlevel! neq 0 ( echo Failed to create Conda environment. Exiting... & pause & exit /b 1 )
) else (
    echo --------------------------------------------------
    echo environment.yaml not found. Skipping Conda environment creation...
    echo --------------------------------------------------
)

pause
popd
popd
endlocal
