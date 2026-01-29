#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# RPMFusion for nonfree packages
dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

packages=() # array of additional packages to install

# hardware enablement
packages+=(mesa-va-drivers-freeworld)

# basic dev tools
packages+=(gcc clang flatpak-builder git-lfs java rustup bash-language-server podman-compose)

# VM support (also relies on podman-compose WinBoat)
packages+=(libvirt libvirt-daemon-config-network libvirt-daemon-kvm virt-install qemu-kvm)

# sysadmin tools
packages+=(fzf htop tailscale wireguard-tools wl-clipboard)

# networking tools
packages+=(wireguard-tools libnatpmp tailscale nmap)

# streaming tools
# packages+=(v4l2loopback)

# install gaming tools
packages+=(steam mangohud)

dnf install -y "${packages[@]}"

dnf remove -y toolbox
dnf autoremove -y

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl disable flatpak-add-fedora-repos.service
