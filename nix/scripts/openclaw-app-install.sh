#!/bin/sh
set -e
mkdir -p "$out/Applications"
app_path="$(find "$src" -maxdepth 2 -name '*.app' -print -quit)"
if [ -z "$app_path" ]; then
  echo "OpenClaw.app not found in $src" >&2
  exit 1
fi

# Canonical name going forward
cp -R "$app_path" "$out/Applications/OpenClaw.app"
