#!/usr/bin/env bash
# TEAM_535: LRU-ish cleaner for tmpfs-backed /tmp, triggered via systemd
set -euo pipefail

# Only operate on a tmpfs-backed /tmp
fstype="$(findmnt -no FSTYPE /tmp 2>/dev/null || true)"
if [ "${fstype:-}" != "tmpfs" ]; then
  exit 0
fi

THRESHOLD_PCT=70
TARGET_PCT=50

usage() {
  df -P /tmp | awk 'NR==2 { gsub(/%$/, "", $5); print $5 }'
}

current="$(usage || echo 0)"
current="${current:-0}"

case "$current" in
  ''|*[!0-9]*) current=0 ;;
esac

if [ "$current" -lt "$THRESHOLD_PCT" ]; then
  exit 0
fi

# Evict least-recently-used top-level entries until we are below TARGET_PCT
while :; do
  current="$(usage || echo 0)"
  current="${current:-0}"

  case "$current" in
    ''|*[!0-9]*) current=0 ;;
  esac

  if [ "$current" -le "$TARGET_PCT" ]; then
    break
  fi

  victim="$(
    find /tmp -mindepth 1 -maxdepth 1 \
      ! -name '.X11-unix' \
      ! -name '.ICE-unix' \
      ! -name '.XIM-unix' \
      ! -name '.font-unix' \
      ! -name 'systemd-private-*' \
      -printf '%A@ %p\n' 2>/dev/null | sort -n | head -n 1 | cut -d' ' -f2- || true
  )"

  if [ -z "${victim:-}" ]; then
    break
  fi

  rm -rf -- "$victim" || true
done
