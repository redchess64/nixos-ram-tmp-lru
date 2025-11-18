# NixOS RAM tmpfs LRU cleaner

This flake provides a systemd service and timer to periodically clean up least-recently-used files from a tmpfs-backed /tmp directory, helping to keep the system's RAM usage under control.

## Usage

Add the following to your `configuration.nix`:

```nix
imports = [
  (fetchFlake "github:veighnsche/nixos-ram-tmp-lru")
];
```
