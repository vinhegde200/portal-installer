@echo off
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

docker login ghcr.io

echo # Env file for docker compose file > .env

echo "Enter the admin password for Identity management system. Identity management system will be setup with user = admin and password you enter here."
set /p admin_password=Enter the admin password (min 8 characters):

echo ENV_ADMIN_PASS=${admin_password} >> .env

echo "Pulling Docker images..."
docker compose pull

if %errorlevel% neq 0 (
  echo "Failed to pull Docker images. Please check your Docker setup."
  exit /b 1
)

echo "Starting the application..."

docker compose up -d

if %errorlevel% neq 0 (
  echo "Failed to start the application. Please check the logs."
  exit /b 1
)

echo "Installation complete. Configure your application at http://localhost:83/#/admin/setup"
