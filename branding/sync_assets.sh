#!/usr/bin/env bash
# Regenerate the logo and copy it into the app and admin.
#   ./branding/sync_assets.sh            (from the repo root)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
L="$ROOT/branding/logo"

python3 "$ROOT/branding/build_logo.py"

# Admin (React)
A="$ROOT/khmer-calendar-admin"
cp "$L/khmer-calendar-icon.svg" "$A/src/assets/brand/khmer-calendar-icon.svg"
cp "$L/khmer-calendar-icon.svg" "$A/public/favicon.svg"
cp "$L/png/favicon-32.png" "$A/public/favicon-32.png"
cp "$L/png/apple-touch-icon-180.png" "$A/public/apple-touch-icon.png"
cp "$L/png/icon-192.png" "$A/public/icon-192.png"
cp "$L/png/icon-512.png" "$A/public/icon-512.png"

# Mobile (Flutter) — launcher icon masters + in-app mark, then platform icons per flavor
M="$ROOT/khmer_calendar_app"
for f in app-icon-1024 app-icon-dev-1024 app-icon-staging-1024 adaptive-foreground-1024 \
         adaptive-foreground-dev-1024 adaptive-foreground-staging-1024 adaptive-background-1024 adaptive-monochrome-1024; do
  cp "$L/png/$f.png" "$M/assets/launcher_icons/$f.png"
done
sips -Z 512 "$L/png/mark-1024.png" --out "$M/assets/branding/logo-mark.png" >/dev/null
(cd "$M" && fvm dart run flutter_launcher_icons)
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp "$M/android/app/src/production/res/mipmap-$d/ic_launcher.png" "$M/android/app/src/main/res/mipmap-$d/ic_launcher.png"
done
echo "Logo synced to admin and app."
