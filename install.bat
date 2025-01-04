@echo off
setlocal enabledelayedexpansion

:: Function to print colored messages
:print_color
set "color_code=%~1"
set "background_code=%~2"
shift
shift
echo.
echo [!color_code!] [!background_code!] %*
echo.
goto :eof

:: Check prerequisites: Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not installed. Please install Docker and try again.
    exit /b 1
)

:: Download configuration files
echo Downloading application files...
curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose.yml
if %errorlevel% neq 0 (
    echo Failed to download compose.yml. Please check your internet connection and try again.
    exit /b 1
)

:: Create .env file
echo # Env file for docker compose file > .env

:: Prompt for admin password
:input_password
set /p "admin_password=Enter the admin password for Identity management system (min 8 characters): "
if not "!admin_password!"=="" if "!admin_password:~7!"=="" (
    echo ENV_ADMIN_PASS=!admin_password! >> .env
) else (
    echo Password must be at least 8 characters long.
    goto input_password
)

:: Pull Docker images
echo Pulling Docker images...
docker compose pull
if %errorlevel% neq 0 (
    echo Failed to pull Docker images. Please check your Docker setup.
    exit /b 1
)

:: Start the application
echo Starting the application...
docker compose up -d
if %errorlevel% neq 0 (
    echo Failed to start the application. Please check the logs.
    exit /b 1
)

:: Verify services
echo Verifying services...
docker compose ps | find "Up" >nul
if %errorlevel% neq 0 (
    echo Some services failed to start. Please check the logs for details.
    exit /b 1
)

:: Success message
echo Installation complete. Configure your application at http://localhost:83/#/admin/setup
exit /b 0
