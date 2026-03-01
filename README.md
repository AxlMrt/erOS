# Eros — NixOS Cybersecurity Workstation

## 1. Introduction

Eros is a NixOS workstation designed for day-to-day cybersecurity work: pentesting, lab operations, and reverse engineering.

Core philosophy:
- keep the base system minimal and clean,
- isolate heavy or risky tooling in devShells,
- drive security and OPSEC through explicit profiles,

Operational goals:
- avoid system pollution,
- reduce attack surface,
- speed up rebuild and audit workflows,
- reduce critical mistakes during engagements.

## 2. Global architecture

### Components

- `flake.nix`: entry point, profiles, outputs, and devShell exports.
- `modules/core`: base system configuration (system, packages, fonts, Hyprland).
- `modules/security`: hardening (sudo, ssh, sysctl).
- `modules/security/secrets-sops.nix`: encrypted secret handling with SOPS.
- `modules/network`: firewall policy + temporary port management (`eros-portctl`).
- `modules/opsec`: identity profile, DNS hygiene, VPN policy, and logging.
- `modules/virtualization`: KVM/libvirt lab setup.
- `modules/home-manager`: user layer (shell, UI, desktop tools).

### Desktop shortcuts (Hyprland)

| Shortcut | Action | Command |
| --- | --- | --- |
| `SUPER + T` | Open terminal | `kitty` |
| `SUPER + D` | Open app launcher | `rofi -show drun` |
| `SUPER + SHIFT + D` | Open command launcher | `rofi -show run` |
| `SUPER + F` | Open browser | `firefox` |
| `SUPER + N` | Toggle notification center | `swaync-client -t` |
| `SUPER + C` | Open clipboard history picker | `cliphist list` |
| `SUPER + Q` | Close focused window | Hyprland action |
| `SUPER + SHIFT + Q` | Exit Hyprland session | Hyprland action |
| `SUPER + H / J / K / L` | Move focus left / down / up / right | Hyprland action |

#### Customizing keybindings

Keybindings are defined in [modules/home-manager/desktop-user/hyprland.nix](modules/home-manager/desktop-user/hyprland.nix).

## 3. Essential commands

### System rebuild

```bash
# Global validation
nix --extra-experimental-features 'nix-command flakes' flake check

# Build without applying
sudo nixos-rebuild build --flake .#default-sec

# Apply immediately
sudo nixos-rebuild switch --flake .#default-sec

# Apply on next boot
sudo nixos-rebuild boot --flake .#default-sec

# Rollback
sudo nixos-rebuild switch --rollback
```

- `switch`: activate now.
- `boot`: activate after reboot.

Useful debug commands:
```bash
nixos-rebuild dry-build --flake .#default-sec
nix flake show
```

### Flake updates

```bash
# Update inputs
nix --extra-experimental-features 'nix-command flakes' flake update

# Validate after update
nix --extra-experimental-features 'nix-command flakes' flake check
```

💡 Best practices:
- update, then test (`build`) before `switch`.
- review the `flake.lock` diff before validating changes.

## 4. DevShells

### Why they exist

devShells isolate heavy/specialized offensive dependencies and prevent base-system contamination.

### How to use them

```bash
nix develop .#web-pentest
nix develop .#windows-ad
nix develop .#reverse
nix develop .#exploit-dev
nix develop .#cloud-pentest
nix develop .#mobile
nix develop .#mobile-ios
nix develop .#hardware
```

### Available devShells

- `web-pentest`: web application testing.
- `network-pentest`: network/protocol assessment.
- `windows-ad`: full AD and Windows protocol operations (baseline + advanced optional tooling).
- `malware-analysis`: full malware analysis baseline (static + dynamic instrumentation essentials).
- `osint`: open-source intelligence tooling.
- `reverse`: reverse engineering workflows.
- `exploit-dev`: exploit build/debug workflow.
- `cloud-pentest`: multi-cloud offensive and audit tooling baseline.
- `mobile`: Android-focused mobile assessment baseline.
- `mobile-ios`: iOS-focused mobile assessment baseline.
- `hardware`: firmware and hardware security baseline.

### Create a new devShell

1. Create `devshells/<name>/default.nix`.
2. Define `pkgs.mkShell { packages = [ ... ]; }`.
3. Export it in `flake.nix` under `devShells`.
4. Test with `nix develop .#<name> -c true`.

💡 Best practices:
- keep each shell minimal and purpose-driven,
- pin through the flake,
- keep heavyweight tooling out of the global system.

## 5. Tool management

### Native tools

Managed centrally in `modules/core/packages.nix`, with package groups separated by type:
- core system baseline,
- archive utilities,
- infrastructure helpers,
- native pentest network baseline,
- desktop-only package set (enabled with Hyprland).

### Isolated tools

Placed in devShells for:
- heavy stacks,
- specialized dependency trees,
- stronger OPSEC boundaries.

### Add a tool correctly

- frequent + low risk → native.
- specialized / engagement-specific / heavy → devShell.

> ⚠️ Attention
> Putting too many offensive tools in the base system increases attack surface and technical debt.

## 6. Network & port management

Firewall policy is profile-driven (`trusted`, `untrusted`, `engagement`, `isolated-offensive`, `lab`) through `modules/network`.

### Temporary port opening

```bash
# Open TCP 8080 for 15 minutes
sudo eros-portctl open tcp 8080 900

# Close explicitly
sudo eros-portctl close tcp 8080
```

Ports are auto-closed when TTL expires.

### Network profiles

- `untrusted`: default offensive profile.
- `engagement`: low-exposure profile for live customer operations.
- `isolated-offensive`: zero-open-port profile for hardened travel/offline contexts.
- `lab`: profile for isolated lab network workflows.
- `trusted`: controlled exposure profile.

💡 OPSEC best practices:
- stay on `untrusted` outside lab activity,
- use short TTL values for temporary openings,
- avoid permanent ad-hoc firewall openings.

## 7. Virtualization & lab

Eros uses KVM/libvirt with desktop lab target:
- `default-lab`: lab + full desktop session (Hyprland + Home Manager).

### Start lab mode (safe)

```bash
# 1) Build only (recommended)
sudo nixos-rebuild dry-build --flake .#default-lab

# 2) Activate lab desktop
sudo nixos-rebuild switch --flake .#default-lab
```

Lab networks:
- `br-lab-int`: internal network.
- `br-lab-dmz`: exposed test-services segment.

Recommended usage:
- AD/DC + clients on `br-lab-int`.
- exposed targets on `br-lab-dmz`.

Snapshots:
- create a snapshot before destructive testing,
- rollback snapshots after each campaign.

## 8. OPSEC & security

Implemented controls:
- identity separation (`clean`, `offensive`, `lab`),
- DNS hygiene via `systemd-resolved`,
- profile-based VPN (OpenVPN),
- bounded logs (`journald` volatile with retention cap),
- encrypted secrets with SOPS.

### Secrets gate

```bash
# Ensure tracked secrets are encrypted and placeholder-free
nix run .#secrets-guard
```

> ⚠️ Attention
> As long as `REPLACE_ME` remains in secret files, the guard intentionally blocks the workflow.

## 9. Recommended workflows

### Bug bounty (web)
1. `nix develop .#web-pentest`
2. run web recon and testing
3. produce report outside shell

### Red team (AD)
1. use `default-sec`
2. `nix develop .#windows-ad`
3. execute with `offensive` identity profile

### Internal lab
1. `sudo nixos-rebuild dry-build --flake .#default-lab`
2. `sudo nixos-rebuild switch --flake .#default-lab`
2. start VMs on lab bridges
3. snapshot before attack simulation

### Emergency rollback workflow
1. select previous generation in bootloader when available
2. or run `sudo nixos-rebuild switch --rollback`
3. verify critical services: `systemctl status greetd libvirtd`
4. inspect boot logs: `journalctl -b -p warning..emerg --no-pager`

### Reverse
1. `nix develop .#reverse`
2. analyze binaries in isolation
3. create PoC in `nix develop .#exploit-dev`

## 10. Maintenance & best practices

- Run regularly:
  ```bash
  nix flake check
  nix run .#secrets-guard
  nix run .#shell-health
  nix run .#qa-check
  ```
- Add features through dedicated modules, not ad-hoc blocks in `flake.nix`.
- Prefer small explicit modules over monolithic generic ones.
- Review periodically:
  - whether native tools are still justified,
  - whether firewall rules are still required,
  - whether obsolete shells can be removed.

💡 Best practices:
- use `build` before `switch`,
- rollback quickly on failure,
- document every new module/devShell when introduced.

## 11. Customization

- Add a host: create `hosts/<name>/` and register it in `flake.nix`.
- Add a user: create `users/<name>/default.nix` and reference it from host settings.
- Add or tune a security profile: adjust profile composition in `flake.nix` (`default-sec`, `default-lab`).
- Add system packages/features: update the relevant module in `modules/`.
- Add user tools/config: update `modules/home-manager/`.
- Customize Hyprland system integration: edit `modules/core/hyprland.nix`.
- Customize keybindings/window behavior: edit `modules/home-manager/desktop-user/hyprland.nix`.
- Customize network/firewall policy: edit `modules/network/default.nix` and profile values in `flake.nix`.
- Customize OPSEC defaults (identity, DNS, VPN, logging): edit `modules/opsec/default.nix`.
- Customize secrets mapping (SOPS keys/files): edit `modules/security/secrets-sops.nix` and `secrets/*.yaml`.
- Add or modify a devShell: edit `devshells/<name>/default.nix` and export it in `flake.nix`.
- Customize lab virtualization/networks: edit `modules/virtualization/lab.nix`.
