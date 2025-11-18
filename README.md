# NixOS RAM tmpfs LRU cleaner

This flake exposes a small NixOS module that:

- mounts `/tmp` as `tmpfs` (`boot.tmp.useTmpfs = true`) and
- runs a systemd service + timer that evicts least‑recently‑used entries from `/tmp`
  when the tmpfs is close to full.

Defaults: start cleaning at ~70% `/tmp` usage, delete LRU top‑level entries until ~50%.

## Usage (flakes)

In your top‑level `flake.nix`:

```nix
{
  inputs.nixos-ram-tmp-lru.url = "github:veighnsche/nixos-ram-tmp-lru";

  outputs = { self, nixpkgs, nixos-ram-tmp-lru, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix

          # Mount /tmp on tmpfs and enable LRU cleaner
          nixos-ram-tmp-lru.nixosModules.tmp-lru-tmp
        ];
      };
    };
}
```

## Behaviour

- `/tmp` is a `tmpfs` with a fixed size (currently 32G).
- A oneshot `tmp-lru-cleaner` service:
  - checks that `/tmp` is `tmpfs`;
  - if usage < 70%, it does nothing;
  - if usage ≥ 70%, it repeatedly removes the least‑recently‑used top‑level entries in `/tmp`
    (based on access time) until usage drops to ≤ 50%.
- A timer unit runs the cleaner periodically after boot.

Thresholds and size are currently hard‑coded in the module; if you need them configurable,
open an issue or send a PR.
