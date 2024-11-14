chcp 65001 > NUL
@echo off

REM Enable delayed expansion for error code evaluation
setlocal enabledelayedexpansion

REM PowerShell command
set PS_CMD=PowerShell -Version 5.1 -ExecutionPolicy Bypass

REM URLs for downloading PortableGit and FFmpeg, and destination paths
set GIT_DL_URL=https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe
set FFMPEG_DL_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
set GIT_DL_DST=%~dp0lib\PortableGit-2.44.0-64-bit.7z.exe
set FFMPEG_DL_DST=%~dp0lib\ffmpeg.zip
set REPO_URL=https://github.com/N01N9/AniTTS-Builder-webUI
set "MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
set "MINICONDA_EXE=%~dp0lib\Miniconda3-latest-Windows-x86_64.exe"
set "INSTALL_PATH=%~dp0lib\Miniconda3"

REM Switch to the directory where the .bat file is located
pushd %~dp0

REM Create lib folder if it doesn't exist
if not exist lib\ ( mkdir lib )

echo --------------------------------------------------
echo PS_CMD: %PS_CMD%
echo GIT_DL_URL: %GIT_DL_URL%
echo GIT_DL_DST: %GIT_DL_DST%
echo FFMPEG_DL_URL: %FFMPEG_DL_URL%
echo REPO_URL: %REPO_URL%
echo --------------------------------------------------
echo.

REM Check CUDA 12.1 installation
echo --------------------------------------------------
echo Checking CUDA 12.1 Installation...
echo --------------------------------------------------
nvcc --version | findstr /i "release 12.1" >nul 2>&1
if %errorlevel% neq 0 (
    echo CUDA 12.1 is not installed.
    pause
    popd
    exit /b 1
) else (
    echo CUDA 12.1 is installed.
)

REM Check cuDNN 9.x installation
echo --------------------------------------------------
echo Checking cuDNN 9.x Installation...
echo --------------------------------------------------
set CUDNN_PATH="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1\bin\cudnn64*.dll"
for %%f in (%CUDNN_PATH%) do (
    powershell -command "(Get-Command '%%f').FileVersionInfo.FileVersion" | findstr /i "^9." >nul 2>&1
    if %errorlevel% neq 0 (
        echo cuDNN 9.x is not installed.
        pause
        popd
        exit /b 1
    ) else (
        echo cuDNN 9.x is installed.
    )
)

REM Check Git installation and download PortableGit if not installed
echo --------------------------------------------------
echo Checking Git Installation...
echo --------------------------------------------------
echo Executing: git --version
git --version
if !errorlevel! neq 0 (
	echo --------------------------------------------------
	echo Git is not installed, so download and use PortableGit.
	echo Downloading PortableGit...
	echo --------------------------------------------------
	echo Executing: curl -L %GIT_DL_URL% -o "%GIT_DL_DST%"
	curl -L %GIT_DL_URL% -o "%GIT_DL_DST%"
	if !errorlevel! neq 0 ( pause & popd & exit /b !errorlevel! )

	echo --------------------------------------------------
	echo Extracting PortableGit...
	echo --------------------------------------------------
	echo Executing: "%GIT_DL_DST%" -y
	"%GIT_DL_DST%" -y
	if !errorlevel! neq 0 ( pause & popd & exit /b !errorlevel! )

	echo --------------------------------------------------
	echo Removing %GIT_DL_DST%...
	echo --------------------------------------------------
	echo Executing: del "%GIT_DL_DST%"
	del "%GIT_DL_DST%"
	if !errorlevel! neq 0 ( pause & popd & exit /b !errorlevel! )

	REM Set Git command path
	echo --------------------------------------------------
	echo Setting up PATH...
	echo --------------------------------------------------
	echo Executing: set "PATH=%~dp0lib\PortableGit\bin;%PATH%"
	set "PATH=%~dp0lib\PortableGit\bin;%PATH%"
	if !errorlevel! neq 0 ( pause & popd & exit /b !errorlevel! )

	echo --------------------------------------------------
	echo Checking Git Installation...
	echo --------------------------------------------------
	echo Executing: git --version
	git --version
	if !errorlevel! neq 0 ( pause & popd & exit /b !errorlevel! )
)

REM Download FFmpeg if not installed
echo --------------------------------------------------
echo Checking FFmpeg Installation...
echo --------------------------------------------------
set "ffmpeg_dir=%~dp0lib\ffmpeg"
if exist "%ffmpeg_dir%" (
    echo FFmpeg is already installed.
) else (
    echo FFmpeg is not installed. Downloading FFmpeg...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%FFMPEG_DL_URL%', '%FFMPEG_DL_DST%')"

    if not exist "%FFMPEG_DL_DST%" (
        echo Failed to download FFmpeg. Exiting...
        pause
        popd
        exit /b 1
    )

    echo Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path '%FFMPEG_DL_DST%' -DestinationPath '%ffmpeg_dir%'"
    del "%FFMPEG_DL_DST%"

    REM Add FFmpeg to PATH
    set "ffmpeg_bin_path=%ffmpeg_dir%\ffmpeg-release-essentials\bin"

    echo FFmpeg installation completed.
)

if exist "%INSTALL_PATH%" (
    echo --------------------------------------------------
    echo Miniconda is already installed at %INSTALL_PATH%.
    echo Skipping installation.
    echo --------------------------------------------------
) else (
    REM Download Miniconda 
    echo --------------------------------------------------
    echo Downloading Miniconda...
    echo --------------------------------------------------
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%MINICONDA_URL%', '%MINICONDA_EXE%')"

    if not exist "%MINICONDA_EXE%" (
        echo Failed to download Miniconda.
        pause
        exit /b 1
    )

    REM Miniconda Installation 
    echo --------------------------------------------------
    echo Installing Miniconda...
    echo --------------------------------------------------
    start /wait "" "%MINICONDA_EXE%" /InstallationType=JustMe /RegisterPython=0 /AddToPath=0 /S /D=%INSTALL_PATH%

    REM Delete the Miniconda installation file after installation. 
    del "%MINICONDA_EXE%"

    REM Add the Miniconda path to the current session and system PATH environment variables. 
    echo --------------------------------------------------
    echo Setting up PATH environment variable for Miniconda...
    echo --------------------------------------------------
    set "PATH=%INSTALL_PATH%;%INSTALL_PATH%\Scripts;%INSTALL_PATH%\Library\bin;%PATH%"
    if %errorlevel% neq 0 ( pause & popd & exit /b %errorlevel% )

    REM Conda initialization (through shell configuration) 
    echo --------------------------------------------------
    echo Initializing Conda for the current session...
    echo --------------------------------------------------
    call "%INSTALL_PATH%\Scripts\activate.bat" >nul 2>&1
    if %errorlevel% neq 0 ( pause & popd & exit /b %errorlevel% )

    echo --------------------------------------------------
    echo Miniconda installation is complete.
    echo --------------------------------------------------
)

REM Clone the repository
echo --------------------------------------------------
echo Cloning repository...
echo --------------------------------------------------
git clone %REPO_URL%
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

REM Move to AniTTS-Builder-webUI folder
pushd AniTTS-Builder-webUI

REM Clone the repository
echo --------------------------------------------------
echo Cloning repository...
echo --------------------------------------------------
git clone https://github.com/SUC-DriverOld/MSST-WebUI "./module/MSST_WebUI"
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

REM Activate the virtual environment
echo --------------------------------------------------
echo Activating the virtual environment...
echo --------------------------------------------------
call conda create -n AniTTS-Builder2-webUI python=3.10 -y
if %errorlevel% neq 0 ( popd & exit /b 1 )

call "%INSTALL_PATH%\Scripts\activate.bat" AniTTS-Builder2-webUI
if %errorlevel% neq 0 ( popd & exit /b 1 )

REM Install PyTorch
echo --------------------------------------------------
echo Installing PyTorch...
echo --------------------------------------------------
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

REM Install other dependencies
echo --------------------------------------------------
echo Installing other dependencies...
echo --------------------------------------------------
pip install -r requirements.txt --only-binary=samplerate
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )
pip uninstall librosa -y
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )
pip install "module/MSST_WebUI/tools/webUI_for_clouds/librosa-0.9.2-py3-none-any.whl
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

REM Start MSST-WebUI model download and initialize
echo ----------------------------------------
echo Environment setup is complete. 
echo ----------------------------------------
python initialize.py
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

REM logger switch
set A_FILE="./logger.py"
set B_FILE="./module/MSST_WebUI/utils/logger.py"

REM a파일을 b파일로 이동하며 원본 삭제
move /y %A_FILE% %B_FILE%
if %errorlevel% neq 0 ( pause & popd & exit /b 1 )

echo ----------------------------------------
echo Model download is complete. Start AniTTS-Builder-webUI.
echo ----------------------------------------
pause

popd
popd
endlocal
