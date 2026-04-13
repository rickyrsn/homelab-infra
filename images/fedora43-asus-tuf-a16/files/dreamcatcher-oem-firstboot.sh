#!/usr/bin/env bash
set -euo pipefail

state_dir="/var/lib/dreamcatcher-oem"
state_file="${state_dir}/firstboot-complete"
note_file="${state_dir}/next-steps.txt"

mkdir -p "${state_dir}"

if [[ -e "${state_file}" ]]; then
  exit 0
fi

cat >"${note_file}" <<'EOF'
Dreamcatcher OEM setup completed.

Suggested next steps for the ASUS TUF A16:
1. Finish Fedora Initial Setup / GNOME Initial Setup.
2. Run `sudo /usr/local/sbin/dreamcatcher-enable-nvidia` if you want the proprietary NVIDIA stack.
3. Verify `asusctl`, `supergfxctl`, and Docker:
   - asusctl -h
   - supergfxctl -s
   - docker --version
   - sudo systemctl status docker
4. Add your final user to the `docker` group if you want rootless Docker CLI access.
5. Test suspend/resume, brightness keys, keyboard lighting, Wi-Fi, and audio.
6. If Secure Boot is enabled, review MOK signing requirements before enabling NVIDIA.
EOF

touch "${state_file}"
systemctl disable dreamcatcher-oem-firstboot.service || true
