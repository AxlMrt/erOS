# Secrets (SOPS)

This directory contains encrypted secrets managed by `sops-nix`.

## Files

- `offensive.yaml`: secrets used by `default-sec-desktop` and `default-sec-headless`
- `lab.yaml`: secrets used by `default-lab-host`

## Expected keys

### offensive.yaml

- `vpn/wireguard/config`
- `vpn/openvpn/client_config`

### lab.yaml

- `vpn/wireguard/config`

## Bootstrap

1. Generate/import age key:
   - `sudo install -m 700 -d /var/lib/sops-nix`
   - `sudo sh -c 'age-keygen -o /var/lib/sops-nix/key.txt'`
   - `sudo chmod 600 /var/lib/sops-nix/key.txt`
2. Add recipients in `.sops.yaml`.
3. Work from ignored local files (recommended):
   - `cp secrets/offensive.yaml secrets/offensive.local.yaml`
   - `cp secrets/lab.yaml secrets/lab.local.yaml`
4. Edit local files, then encrypt into tracked files:
   - `sops -e secrets/offensive.local.yaml > secrets/offensive.yaml`
   - `sops -e secrets/lab.local.yaml > secrets/lab.yaml`
5. Remove local plaintext files:
   - `shred -u secrets/offensive.local.yaml secrets/lab.local.yaml`

Alternative (in-place) encryption:
   - `sops -e -i secrets/offensive.yaml`
   - `sops -e -i secrets/lab.yaml`

## Validation

- Run: `nix run .#secrets-guard`
- The `rebuild` alias now executes this check before `nixos-rebuild`.

## Security Best Practices

**Safe to commit**:
- `offensive.yaml` and `lab.yaml` (encrypted with SOPS)
- `.sops.yaml` (contains only public keys)
- This README and `.gitignore`

**Never commit**:
- `/var/lib/sops-nix/key.txt` (private age key)
- `*.local.yaml` files (plaintext versions)
- Any unencrypted secrets

Encrypted files can only be decrypted by machines with the private key.
