# ErOS

A reproducible NixOS + Home Manager setup with profile-based outputs.

## Overview

ErOS is built around:

- host-based system configuration,
- reusable modules,
- user-session configuration via Home Manager,
- selectable profiles (`base`, `desktop`, `pentest`).

## Requirements

- NixOS with flakes enabled
- a configured host under `hosts/<name>/`
- a matching user entrypoint under `users/<name>/`

## Quick Start

```bash
# Validate
nix --extra-experimental-features 'nix-command flakes' flake check

# Apply desktop profile for default host
sudo nixos-rebuild switch --flake .#default-desktop

# Apply full pentest profile for default host
sudo nixos-rebuild switch --flake .#default-pentest

# Update inputs
nix --extra-experimental-features 'nix-command flakes' flake update
```

## Keybindings

Hyprland keybindings currently configured:

- `SUPER + F` → launch Firefox
- `SUPER + T` → launch Kitty
- `SUPER + D` → open app launcher (`rofi -show drun`)
- `SUPER + Q` → close active window
- `SUPER + E` → exit Hyprland session

## Project Layout

- `flake.nix` — inputs, host map, output generation
- `hosts/` — machine-specific hardware + policy
- `modules/core/` — base system modules
- `modules/desktop-system/` — system desktop stack (Hyprland services, audio, portals)
- `modules/pentest/` — offensive tooling by category
- `modules/home-manager/` — reusable user-session modules
- `users/` — per-user Home Manager entrypoints

## Customization

- Add a host: create `hosts/<name>/` and register it in `flake.nix`.
- Add a user: create `users/<name>/default.nix` and reference it from host settings.
- Add system packages/features: update the relevant module in `modules/`.
- Add user tools/config: update `modules/home-manager/`.
