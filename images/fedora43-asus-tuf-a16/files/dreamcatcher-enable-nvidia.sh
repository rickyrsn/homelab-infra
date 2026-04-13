#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

log() {
  printf '[dreamcatcher-nvidia] %s\n' "$*"
}

install_copr_support() {
  dnf -y install dnf5-plugins dnf-plugins-core >/dev/null 2>&1 || true
}

enable_rpm_fusion() {
  log "Enabling RPM Fusion repositories"
  dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
}

install_nvidia_stack() {
  log "Installing NVIDIA packages"
  dnf -y install \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-power
}

set_grub_args() {
  local current_args
  current_args="$(grubby --info=ALL | awk -F= '/^args=/{print $2}' | tr -d '\"' | tr ' ' '\n' | sort -u)"

  for arg in rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1; do
    if ! grep -qx "${arg}" <<<"${current_args}"; then
      log "Adding kernel arg: ${arg}"
      grubby --update-kernel=ALL --args="${arg}"
    fi
  done
}

enable_services() {
  log "Enabling NVIDIA power services and supergfxd"
  systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
  systemctl enable --now supergfxd.service
  systemctl mask nvidia-fallback.service || true
}

install_copr_support
enable_rpm_fusion
install_nvidia_stack
set_grub_args
enable_services

log "NVIDIA staging complete. Reboot to load the new driver stack."
