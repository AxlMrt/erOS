# Secrets (SOPS)

This directory contains encrypted secrets managed by `sops-nix`.

## Files

- `secrets.yaml`: encrypted secrets used by `default`

## Expected keys

### secrets.yaml

- `vpn/openvpn/client_config`

## Bootstrap

1. Generate/import age key:
   - `sudo install -m 700 -d /var/lib/sops-nix`
   - `sudo sh -c 'age-keygen -o /var/lib/sops-nix/key.txt'`
   - `sudo chmod 600 /var/lib/sops-nix/key.txt`
2. Add recipients in `.sops.yaml`.
3. Work from ignored local files (recommended):
   - `cp secrets/secrets.yaml secrets/secrets.local.yaml`
4. Edit local files, then encrypt into tracked files:
   - `sops -e secrets/secrets.local.yaml > secrets/secrets.yaml`
5. Remove local plaintext files:
   - `shred -u secrets/secrets.local.yaml`

Alternative (in-place) encryption:
   - `sops -e -i secrets/secrets.yaml`

## Validation

- Run: `nix run .#secrets-guard`
- Recommended before apply: `nix run .#qa-check -- full` then `sudo nixos-rebuild switch --flake .#default`.

## Security Best Practices
**Never commit**:
- `/var/lib/sops-nix/key.txt` (private age key)
- `*.local.yaml` files (plaintext versions)
- Any unencrypted secrets

Encrypted files can only be decrypted by machines with the private key.
