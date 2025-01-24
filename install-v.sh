#!/bin/bash

print_color() {
  local color_code=$1
  local back_color=$2
  shift
  shift
  echo ""
  echo -e "\e[${color_code};${back_color}m$@\e[0m"
  echo ""
}

# Check prerequisites
if ! command -v docker &>/dev/null; then
  print_color 31 41 "Docker is not installed. Please install Docker and try again."
  exit 1
fi

# Clone or download configuration files
print_color 31 43 "Downloading application files..."
if ! curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-v.yml; then
  print_color 31 41 "Failed to download compose.yml. Please check your internet connection and try again."
  exit 1
fi

# Create the env file with necessary environment variables
echo "# Env file for docker compose file" > .env

while true; do
  print_color 31 43 "Enter the admin password for Identity management system. Identity management system will be setup with user = admin and password you enter here."
  read -s -p "Enter the admin password (min 8 characters): " admin_password
  echo
  if [ ${#admin_password} -ge 8 ]; then
    break
  else
    print_color 31 43 "Password must be at least 8 characters long."
  fi
done

echo "ENV_ADMIN_PASS=${admin_password}" >> .env

# Capture the version to be installed
read -s -p "Enter the version to be installed: " image_version

print_color 31 43 "Installing the version ${image_version}"
echo "ENV_IMAGE_VER=${image_version}" >> .env

# Pull Docker images
print_color 31 43 "Pulling Docker images..."
if ! docker compose pull; then
  print_color 31 41 "Failed to pull Docker images. Please check your Docker setup."
  exit 1
fi

# Start the application
print_color 31 43 "Starting the application..."
if ! docker compose up -d; then
  print_color 31 41 "Failed to start the application. Please check the logs."
  exit 1
fi

# Verify services
if docker compose ps | grep -q "Up"; then
  print_color 32 42 "Installation complete. Configure your application at http://localhost:83/#/admin/setup"
else
  print_color 31 41 "Some services failed to start. Please check the logs for details."
fi
