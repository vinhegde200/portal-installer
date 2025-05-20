@echo off
setlocal enabledelayedexpansion

REM Choose containerization tool
echo Select the containerization tool you want to use:
echo 1. Podman
echo 2. Docker
set /p container_choice="Enter your choice (1 or 2): "

if "%container_choice%"=="1" (
    echo You have selected Podman.
    podman --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo Podman is not installed. Please install Podman and try again.
        exit /b 1
    )
) else if "%container_choice%"=="2" (
    echo You have selected Docker.
    docker --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo Docker is not installed. Please install Docker and try again.
        exit /b 1
    )
) else (
    echo Invalid choice. Please run the script again and select a valid option.
    exit /b 1
)

REM Select eflow type
echo Select the type of eflow you want to install:
echo 1. Central eflow
echo 2. Local eflow
set central_eflow=true
set eflow_version=12.2.122040.24
set /p eflow_choice=Enter your choice (1 or 2):

if "%eflow_choice%"=="1" (
    echo You have selected Central eflow.
) else if "%eflow_choice%"=="2" (
    echo You have selected Local eflow.
    set central_eflow=false
    set /p user_version="Enter eflow version (default is 12.2.122040.24): "
    if not "%user_version%"=="" (
        set eflow_version=%user_version%
    )
) else (
    echo Invalid choice. Please run the script again and select a valid option.
    exit /b 1
)

REM Download configuration files
echo Downloading application files...
if "%central_eflow%"=="true" (
    curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-v2-windows.yml
) else (
    curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-v2-eflow-windows.yml
)
if %errorlevel% neq 0 (
    echo Failed to download compose.yml. Please check your internet connection and try again.
    exit /b 1
)

REM Ask for admin password
echo # Env file for docker compose file > .env
:ask_password
echo Enter the admin password for Identity management system. It must be at least 8 characters:
set /p admin_password=Password: 
call set char=%%admin_password:~7,1%%
if "!char!"=="" (
    echo Password must be at least 8 characters long.
    goto ask_password
)

echo ENV_ADMIN_PASS=%admin_password% >> .env

set /p image_version=Enter the version you want to install (e.g. v12.1.8): 
echo ENV_IMAGE_VER=%image_version% >> .env
echo EFLOW_VERSION=%eflow_version% >> .env

REM Pull images
echo Pulling images...
if "%container_choice%"=="1" (
    podman compose -f compose.yml pull
) else (
    docker compose -f compose.yml pull
)
if %errorlevel% neq 0 (
    echo Failed to pull images. Please check your container setup.
    exit /b 1
)

REM Start the application
echo Starting the application...
if "%container_choice%"=="1" (
    podman compose -f compose.yml up -d
) else (
    docker compose -f compose.yml up -d
)
if %errorlevel% neq 0 (
    echo Failed to start the application. Please check the logs.
    exit /b 1
)

REM Verify services
echo Verifying services...
if "%container_choice%"=="1" (
    podman compose ps | findstr "Up" >nul
) else (
    docker compose ps | findstr "Up" >nul
)

if %errorlevel% equ 0 (
    echo Installation complete. Configure your application at http://localhost:8083/#/admin/setup
) else (
    echo Some services failed to start. Please check the logs for details.
)

endlocal
