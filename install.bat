@echo off
REM Print colored messages (simple echo for Windows)
setlocal enabledelayedexpansion

REM Check prerequisites: Podman
podman --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Podman is not installed. Please install Podman and try again.
    exit /b 1
)

REM Download configuration files
echo Downloading application files...
curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-v2.yml
if %errorlevel% neq 0 (
    echo Failed to download compose.yml. Please check your internet connection and try again.
    exit /b 1
)

curl -o compose-eflow.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/eflow/compose.yaml
if %errorlevel% neq 0 (
    echo Failed to download compose.yml of eflow. Please check your internet connection and try again.
    exit /b 1
)


podman login ghcr.io

REM Select eflow type
echo Select the type of eflow you want to install:
echo 1. Central eflow
echo 2. Local eflow
set /p eflow_choice=Enter your choice (1 or 2):

set central_eflow=true
set eflow_version=12.2.122040.24

if "%eflow_choice%"=="1" (
    echo You have selected Central eflow.
) else if "%eflow_choice%"=="2" (
    echo You have selected Local eflow.
    set central_eflow=false
    set /p eflow_version=Please enter eflow version, if you want default press enter:
    if "%eflow_version%"=="" (
        set eflow_version=12.2.122040.24
    )
) else (
    echo Invalid choice. Please run the script again and select a valid option.
    exit /b 1
)

REM Create the env file with necessary environment variables
echo # Env file for docker compose file > .env

:ask_password
echo Enter the admin password for Identity management system. Identity management system will be setup with user = admin and password you enter here.
set /p admin_password=Enter the admin password (min 8 characters):
if not "%admin_password:~7,1%"=="" (
    goto password_ok
)
echo Password must be at least 8 characters long.
goto ask_password

:password_ok
echo ENV_ADMIN_PASS=%admin_password% >> .env

REM Capture the version to be installed
set /p image_version=Enter the version to be installed:

echo Installing the version %image_version%
echo ENV_IMAGE_VER=%image_version% >> .env
echo EFLOW_VERSION=%eflow_version% >> .env

REM Pull Docker images
echo Pulling Docker images...
podman compose -f compose.yml pull
if %errorlevel% neq 0 (
    echo Failed to pull Docker images. Please check your Docker setup.
    exit /b 1
)

REM If central_eflow is false, pull the eflow image
if "%central_eflow%"=="false" (
    echo Pulling eflow image...
    podman compose -f compose-eflow.yml pull
    if %errorlevel% neq 0 (
        echo Failed to pull eflow image. Please check your Docker setup.
        exit /b 1
    )
)

REM Start the application
echo Starting the application...
podman compose up -d
if %errorlevel% neq 0 (
    echo Failed to start the application. Please check the logs.
    exit /b 1
)

if "%central_eflow%"=="false" (
    echo Starting eflow...
    podman compose -f compose-eflow.yml up -d
    if %errorlevel% neq 0 (
        echo Failed to start eflow. Please check the logs.
        exit /b 1
    )
)

REM Verify services
podman compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo Installation complete. Configure your application at http://localhost:8083/#/admin/setup
) else (
    echo Some services failed to start. Please check the logs for details.
)