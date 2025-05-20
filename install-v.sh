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

# choose which containerization tools wants to use. podman or docker
print_color 31 43 "Select the containerization tool you want to use:"
print_color 31 43 "1. Podman"
print_color 31 43 "2. Docker"
read -p "Enter your choice (1 or 2): " container_choice
if [[ "$container_choice" == "1" ]]; then
  print_color 31 43 "You have selected Podman."
  # Check if Podman is installed
  if ! command -v podman &>/dev/null; then
    print_color 31 41 "Podman is not installed. Please install Podman and try again."
    exit 1
  fi
elif [[ "$container_choice" == "2" ]]; then
  print_color 31 43 "You have selected Docker."
  # Check if Docker is installed
  if ! command -v docker &>/dev/null; then
    print_color 31 41 "Docker is not installed. Please install Docker and try again."
    exit 1
  fi
else
  print_color 31 41 "Invalid choice. Please run the script again and select a valid option."
  exit 1
fi

# set bool variable for central eflow
central_eflow=true
eflow_version="12.2.122040.24"
# select eflow type. localhosted or central
print_color 31 43 "Select the type of eflow you want to install:"
print_color 31 43 "1. Central eflow"
print_color 31 43 "2. Local eflow"
read -p "Enter your choice (1 or 2): " eflow_choice
if [[ "$eflow_choice" == "1" ]]; then
  print_color 31 43 "You have selected Central eflow."
elif [[ "$eflow_choice" == "2" ]]; then
  print_color 31 43 "You have selected Local eflow."
  central_eflow=false
  print_color 31 43 "Please enter eflow version, if you want default press enter:"
  read -p "Enter the version to be installed: " eflow_version
  if [ -z "$eflow_version" ]; then
    eflow_version="12.2.122040.24"
  fi
else
  print_color 31 41 "Invalid choice. Please run the script again and select a valid option."
  exit 1
fi

print_color 31 43 "Downloading application files..."
if ["$container_choice" == "1" ]; then #podman
  # if central_eflow is true, set the eflow version to latest
  if [ "$central_eflow" = true ]; then
    # Clone or download configuration files
    if ! curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-podman.yml; then
      print_color 31 41 "Failed to download compose.yml. Please check your internet connection and try again."
      exit 1
    fi
  else
    # Clone or download configuration files
    if ! curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-podman-eflow.yml; then
      print_color 31 41 "Failed to download compose.yml. Please check your internet connection and try again."
      exit 1
    fi
  fi
else #docker
  # if central_eflow is true, set the eflow version to latest
  if [ "$central_eflow" = true ]; then
    # Clone or download configuration files
    if ! curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-v2.yml; then
      print_color 31 41 "Failed to download compose.yml. Please check your internet connection and try again."
      exit 1
    fi
  else
    # Clone or download configuration files
    if ! curl -o compose.yml https://raw.githubusercontent.com/vinhegde200/portal-installer/refs/heads/main/compose-docker-eflow.yml; then
      print_color 31 41 "Failed to download compose.yml. Please check your internet connection and try again."
      exit 1
    fi
  fi
fi

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

# Create the env file with necessary environment variables
echo "# Env file for docker compose file" > .env
echo "ENV_ADMIN_PASS=${admin_password}" >> .env

# Capture the version to be installed
read -p "Enter the version to be installed: " image_version

print_color 31 43 "Installing the version ${image_version}"
echo "ENV_IMAGE_VER=${image_version}" >> .env
echo "EFLOW_VERSION=${eflow_version}" >> .env

# Pull Docker images
print_color 31 43 "Pulling Docker images..."
if [ "$container_choice" == "1" ]; then
  if ! podman compose -f compose.yaml pull; then
    print_color 31 41 "Failed to pull Docker images. Please check your Docker setup."
    exit 1
  fi
else
  if ! docker compose -f compose.yaml pull; then
    print_color 31 41 "Failed to pull Docker images. Please check your Docker setup."
    exit 1
  fi
fi

# Start the application
print_color 31 43 "Starting the application..."
if [ "$container_choice" == "1" ]; then
  if ! podman compose up -d; then
    print_color 31 41 "Failed to start the application. Please check the logs."
    exit 1
  fi
else
  if ! docker compose up -d; then
    print_color 31 41 "Failed to start the application. Please check the logs."
    exit 1
  fi
fi

# Verify services
if [ "$container_choice" == "1" ]; then
  # Check if Podman is running
  if podman compose ps | grep -q "Up"; then
    print_color 31 43 "Installation complete. Configure your application at http://localhost:8083/#/admin/setup"
    exit 1
  fi
  else
     print_color 31 41 "Some services failed to start. Please check the logs for details."
  fi
else
  # Check if Docker is running
  if docker compose ps | grep -q "Up"; then
    print_color 31 41 "Docker is not running. Please start Docker and try again."
    exit 1
  fi
  else 
    print_color 31 41 "Some services failed to start. Please check the logs for details."
  fi
fi