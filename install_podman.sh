for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Podman's official repository and install Podman
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Add the Kubic project (official Podman repo) GPG key and repo
. /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${ID}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${ID}_${VERSION_ID}/Release.key" | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y podman podman-compose

# Optional: Enable user namespaces for rootless Podman (recommended)
sudo sysctl kernel.unprivileged_userns_clone=1