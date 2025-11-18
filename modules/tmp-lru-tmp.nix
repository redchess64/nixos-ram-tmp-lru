{ config, pkgs, lib, ... }:

let
  tmpLruCleanerScript =
    pkgs.writeShellScript "tmp-lru-cleaner"
      (builtins.readFile ../pkgs/tmp-lru-cleaner.sh);
in
{
  # TEAM_535: tmpfs /tmp with periodic LRU-ish cleaner, reusable module
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "32G";

  systemd.services.tmp-lru-cleaner = {
    description = "LRU-ish /tmp tmpfs cleaner";
    path = [ pkgs.coreutils pkgs.findutils pkgs.util-linux pkgs.gawk ];
    serviceConfig = {
      Type = "oneshot";
      Nice = 10;
      ExecStart = "${tmpLruCleanerScript}";
    };
  };

  systemd.timers.tmp-lru-cleaner = {
    description = "Trigger LRU-ish /tmp tmpfs cleaner";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "15m";
      AccuracySec = "5m";
    };
  };
}
