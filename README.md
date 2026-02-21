# ErOS

A reproducible, minimal, productivity-focused NixOS + Home Manager setup.

## Overview

ErOS is built around:

- host-based system configuration,
- reusable modules,
- user-session configuration via Home Manager,
- selectable profiles (`base`, `desktop`, `pentest`).
- a unified design system (single palette, typography, spacing).

## Requirements

- NixOS with flakes enabled
- a configured host under `hosts/<name>/`
- a matching user entrypoint under `users/<name>/`

## Quick Start

```bash
# Validate
nix --extra-experimental-features 'nix-command flakes' flake check

# Available outputs
nix flake show

# Apply desktop profile for default host
sudo nixos-rebuild switch --flake .#default-desktop

# Apply full pentest profile for default host
sudo nixos-rebuild switch --flake .#default-pentest

# Update inputs
nix --extra-experimental-features 'nix-command flakes' flake update
```

## UX Stack

- WM/session: Hyprland + greetd
- Bar: Waybar (essential + light perf)
- Launcher: Rofi (`drun`, `run`)
- Terminal: Kitty
- Shell/prompt: Zsh + Starship
- Notifications: swaync
- Clipboard: wl-clipboard + cliphist

## Keybindings

Hyprland keybindings currently configured:

- `SUPER + T` → launch Kitty
- `SUPER + D` → launcher (`rofi -show drun`)
- `SUPER + SHIFT + D` → command runner (`rofi -show run`)
- `SUPER + F` → launch Firefox
- `SUPER + N` → toggle notification center
- `SUPER + C` → clipboard history picker
- `SUPER + Q` → close active window
- `SUPER + SHIFT + Q` → exit Hyprland session
- `SUPER + H/J/K/L` → move focus

## Project Layout

- `flake.nix` — inputs, host map, output generation
- `hosts/` — machine-specific hardware + policy
- `modules/core/` — base system modules
- `modules/desktop-system/` — system desktop stack (Hyprland services, audio, portals)
- `modules/pentest/` — offensive tooling by category
- `modules/home-manager/` — user-session entrypoint
- `modules/home-manager/theme|launcher|waybar|terminal|notifications|desktop-user|shell|editors|clipboard/` — HM feature modules
- `modules/home-manager/shell/` — shell + prompt layer
- `users/` — per-user Home Manager entrypoints

## Migration & Rollback

Recommended migration sequence:

```bash
# 1) Validate full graph
nix --extra-experimental-features 'nix-command flakes' flake check

# 2) Build before switch
sudo nixos-rebuild build --flake .#default-desktop

# 3) Apply desktop profile
sudo nixos-rebuild switch --flake .#default-desktop
```

If needed, rollback instantly:

```bash
sudo nixos-rebuild switch --rollback
```

## Customization

- Add a host: create `hosts/<name>/` and register it in `flake.nix`.
- Add a user: create `users/<name>/default.nix` and reference it from host settings.
- Add system packages/features: update the relevant module in `modules/`.
- Add user tools/config: update `modules/home-manager/`.
