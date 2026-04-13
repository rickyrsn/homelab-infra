# Fedora 43 OEM installer recipe for ASUS TUF A16 FA608UH.
# This workflow assumes the laptop's internal drive is /dev/nvme0n1 and will be wiped.

text --non-interactive
eula --agreed
lang en_US.UTF-8
keyboard us
timezone Asia/Jakarta --utc
network --bootproto=dhcp --device=link --activate --onboot=on
firewall --disabled
selinux --enforcing
bootloader --timeout=1 --append="rhgb quiet supergfxd.mode=Hybrid"
zerombr
clearpart --all --initlabel --disklabel=gpt --drives=nvme0n1
ignoredisk --only-use=nvme0n1
firstboot --reconfig
rootpw --lock
reboot

part /boot/efi --fstype=efi --size=600 --ondisk=nvme0n1
part /boot --fstype=ext4 --size=1024 --ondisk=nvme0n1
part swap --fstype=swap --size=16384 --ondisk=nvme0n1
part / --fstype=ext4 --size=32768 --ondisk=nvme0n1
part /home --fstype=ext4 --size=35440 --ondisk=nvme0n1
part /tmp --fstype=ext4 --size=8192 --fsoptions="nodev,nosuid" --ondisk=nvme0n1
part /var --fstype=ext4 --size=20480 --ondisk=nvme0n1
part /var/tmp --fstype=ext4 --size=8192 --fsoptions="nodev,nosuid" --ondisk=nvme0n1
part /var/log --fstype=ext4 --size=8192 --ondisk=nvme0n1

%post --log=/root/ks-post.log --erroronfail
set -euxo pipefail

mkdir -p /usr/local/sbin /usr/lib/systemd/system /var/lib/dreamcatcher-oem

cat >/usr/local/sbin/dreamcatcher-enable-nvidia <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

log() {
  printf '[dreamcatcher-nvidia] %s\n' "$*"
}

dnf -y install dnf5-plugins dnf-plugins-core >/dev/null 2>&1 || true

log "Enabling RPM Fusion repositories"
dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

log "Installing NVIDIA packages"
dnf -y install \
  akmod-nvidia \
  xorg-x11-drv-nvidia \
  xorg-x11-drv-nvidia-cuda \
  xorg-x11-drv-nvidia-power

current_args="$(grubby --info=ALL | awk -F= '/^args=/{print $2}' | tr -d '\"' | tr ' ' '\n' | sort -u)"
for arg in rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1; do
  if ! grep -qx "${arg}" <<<"${current_args}"; then
    grubby --update-kernel=ALL --args="${arg}"
  fi
done

systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
systemctl enable --now supergfxd.service
systemctl mask nvidia-fallback.service || true

log "NVIDIA staging complete. Reboot to load the new driver stack."
EOF
chmod 0755 /usr/local/sbin/dreamcatcher-enable-nvidia

cat >/usr/local/sbin/dreamcatcher-oem-firstboot <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state_dir="/var/lib/dreamcatcher-oem"
state_file="${state_dir}/firstboot-complete"
note_file="${state_dir}/next-steps.txt"

mkdir -p "${state_dir}"

if [[ -e "${state_file}" ]]; then
  exit 0
fi

cat >"${note_file}" <<'NOTE'
Dreamcatcher OEM setup completed.

Suggested next steps for the ASUS TUF A16:
1. Finish Fedora Initial Setup / GNOME Initial Setup.
2. Run `sudo /usr/local/sbin/dreamcatcher-enable-nvidia` if you want the proprietary NVIDIA stack.
3. Verify `asusctl` and `supergfxctl`:
   - asusctl -h
   - supergfxctl -s
4. Test suspend/resume, brightness keys, keyboard lighting, Wi-Fi, and audio.
5. If Secure Boot is enabled, review MOK signing requirements before enabling NVIDIA.
NOTE

touch "${state_file}"
systemctl disable dreamcatcher-oem-firstboot.service || true
EOF
chmod 0755 /usr/local/sbin/dreamcatcher-oem-firstboot

cat >/etc/sysctl.d/60-dreamcatcher-cis-workstation.conf <<'EOF'
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
EOF

cat >/etc/modprobe.d/dreamcatcher-cis-workstation.conf <<'EOF'
install cramfs /bin/false
install freevxfs /bin/false
install hfs /bin/false
install hfsplus /bin/false
install jffs2 /bin/false
install squashfs /bin/false
install udf /bin/false
EOF

cat >/usr/lib/systemd/system/dreamcatcher-oem-firstboot.service <<'EOF'
[Unit]
Description=Dreamcatcher OEM first-boot tasks
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/dreamcatcher-oem/firstboot-complete

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dreamcatcher-oem-firstboot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

dnf -y install dnf5-plugins dnf-plugins-core >/dev/null 2>&1 || true
dnf -y copr enable lukenukem/asus-linux
dnf -y install asusctl supergfxctl
dnf -y install asusctl-rog-gui || true

dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl disable --now firewalld.service || true
systemctl mask firewalld.service || true
systemctl enable docker.service
systemctl enable supergfxd.service
systemctl enable dreamcatcher-oem-firstboot.service

touch /etc/dreamcatcher-cis-workstation

mkdir -p /etc/systemd/system.conf.d
cat >/etc/systemd/system.conf.d/10-dreamcatcher-oem.conf <<'EOF'
[Manager]
DefaultTimeoutStopSec=15s
EOF

%end
