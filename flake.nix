{
  description = "NixOS RAM tmpfs LRU cleaner";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }: {
    nixosModules.tmp-lru-tmp = import ./modules/tmp-lru-tmp.nix;
  };
}
