# Fedora 43 ASUS TUF A16 OEM Installer

This directory contains a Fedora-native image build workflow for an OEM-style Fedora 43 Workstation installer ISO for the ASUS TUF A16 FA608UH.

The design goals are:

- install Fedora 43 Workstation onto the laptop as a mostly pre-configured OEM image
- defer final user creation and personalization to Fedora Initial Setup / GNOME Initial Setup
- follow [asus-linux.org](https://asus-linux.org/) guidance for ASUS control tooling and graphics switching
- stage NVIDIA enablement after install instead of baking proprietary drivers into the base image
- keep the storage recipe opinionated for this laptop with a practical CIS-style split-mount layout

## Layout

```text
images/fedora43-asus-tuf-a16/
├── Makefile
├── README.md
├── blueprints/
│   └── metadata.toml
├── files/
│   ├── dreamcatcher-enable-nvidia.sh
│   ├── dreamcatcher-oem-firstboot.service
│   └── dreamcatcher-oem-firstboot.sh
├── generated/
│   └── .gitkeep
├── kickstarts/
│   └── asus-tuf-a16-oem.ks
├── package-lists/
│   └── daily-driver-dev.txt
└── scripts/
    └── render-blueprint.sh
```

## What Gets Built

The intended output is a Fedora 43 `workstation-live-installer` ISO that:

- targets `x86_64`
- assumes UEFI boot
- wipes the internal `nvme0n1` disk by default
- installs a split-mount workstation layout that uses about 128 GiB total and leaves the rest of the disk unallocated
- lands in OEM first boot with `firstboot --reconfig`
- installs `asusctl` and `supergfxctl` during `%post`
- installs Docker Engine from Docker's Fedora repository during `%post`
- disables `firewalld` by design for this profile
- enables `supergfxd.service`
- drops helper scripts into the installed OS for first-boot notes and optional NVIDIA setup

## Prerequisites

Build this on a Fedora host with Image Builder available.

- Fedora host with `osbuild-composer` and `composer-cli`
- a running `osbuild-composer.socket`
- enough disk space for a Workstation live installer compose
- network access during compose and during the installation `%post` phase

Typical package set on the build host:

```bash
sudo dnf install -y osbuild-composer composer-cli
sudo systemctl enable --now osbuild-composer.socket
```

## Quick Start

Render the blueprint TOML from the package list and Kickstart source:

```bash
cd /Users/ricky/Documents/personal/dreamcatcher-infrastructure/images/fedora43-asus-tuf-a16
make render
```

If `composer-cli` is installed, validate that Image Builder can parse and depsolve the blueprint:

```bash
make validate
```

Start the ISO compose:

```bash
make build
```

Check build state and fetch the finished artifact:

```bash
make status
make image UUID=<compose-uuid>
```

## ASUS Linux Notes

This workflow follows ASUS Linux guidance in a conservative way:

- install `asusctl` and `supergfxctl`
- install Docker instead of Podman
- enable `supergfxd.service`
- prefer `Hybrid` mode on first boot
- do not force a proprietary NVIDIA stack into the base image
- keep Secure Boot decisions separate from the base installer

## Hardening Notes

This profile now applies a practical CIS-style workstation baseline, not formal CIS compliance:

- split mounts for `/tmp`, `/var`, `/var/tmp`, and `/var/log`
- SELinux enforcing
- root account locked
- a small sysctl baseline for redirects and martian logging
- unused filesystem modules disabled

Deliberate deviations from a strict CIS benchmark:

- `firewalld` is disabled at your request
- Docker is installed instead of the more conservative container defaults
- the remaining disk capacity is intentionally left unallocated

The helper script `dreamcatcher-enable-nvidia.sh` intentionally performs the RPM Fusion and NVIDIA steps only after installation, because that is the least risky default for a fresh OEM-style Fedora install on hybrid AMD/NVIDIA hardware.

## Important Assumptions

- target machine: ASUS TUF A16 FA608UH
- internal install target: `/dev/nvme0n1`
- install mode: destructive full-disk wipe
- no LUKS in v1
- stock Fedora kernel by default

If any of those assumptions change, update the Kickstart before using the installer on real hardware.
