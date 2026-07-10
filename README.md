# NixOS Installation Guide

## Prerequisites

- UEFI firmware with TPM2 support
- Secure Boot disabled initially

## Installation

Boot from NixOS installer, then:

```bash
sudo -i
loadkeys de

# Partition and format
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
    --mode destroy,format,mount --flake github:jhelfer/nixos-config#WS1061

# Install
nixos-install --flake github:jhelfer/nixos-config#WS1061
reboot
```

## First Boot

1. Enter LUKS passphrase manually
2. System generates Secure Boot keys and reboots automatically

## Enable Secure Boot

Enter BIOS after the automatic reboot:

1. Enable **Secure Boot**
2. Save and exit

On next boot, keys are enrolled automatically.

## Enroll TPM2 for Auto-Unlock

After Secure Boot is active:

```bash
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-swap --tpm2-device=auto --tpm2-pcrs=7
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-root --tpm2-device=auto --tpm2-pcrs=7
```

## Verify

```bash
sudo bootctl status # Should show "Secure Boot: enabled (user)"
sudo nix run nixpkgs#sbctl verify # All boot files should be signed
```
