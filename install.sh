#!/bin/bash

print_color() {
  local color_code=$1
  local back_color=$2
  shift
  shift
  echo "";
  echo -e "\e[${color_code};${back_color}m$@\e[0m"
  echo "";
}

# Check prerequisites
if ! command -v docker &>/dev/null; then
  echo "Docker is not installed. Please install Docker and try again."
  exit 1
fi

# Clone or download configuration files
print_color 31 43 "Downloading application files..."
curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose.yml

# Create the env file with necessary environment variables
echo "# Env file for docker compose file" > .env

print_color 31 43 "Enter the admin password for Identity management system. Identity management system will be setup with user = admin and password you enter here."
read -p "Enter the admin password: " admin_password

echo "ENV_ADMIN_PASS=${admin_password}" >> .env


# Pull Docker images
print_color 31 43 "Pulling Docker images..."
docker compose pull

# Start the application
print_color 31 43 "Starting the application..."
docker compose up -d

print_color 31 43 "Installation complete. Configure your application at http://localhost:83/#/admin/setup"
