{
  description = "NixOS RAM tmpfs LRU cleaner";
  outputs = _: {
    nixosModules.tmp-lru-tmp = import ./modules/tmp-lru-tmp.nix;
  };
}
