#!/usr/bin/env bash

set -euo pipefail

# ==========================================
# Alwaysdata Xray installer
# ==========================================

XRAY_DIR="$HOME/xray"
CONFIG="$XRAY_DIR/config.json"
PORT="${XRAY_PORT:-8300}"
WS_PATH="${XRAY_PATH:-/xray}"

echo
echo "=========================================="
echo " Alwaysdata Xray installer"
echo "=========================================="
echo

# Basic checks
if [ "$(uname -s)" != "Linux" ]; then
    echo "ERROR: This installer requires Linux."
    exit 1
fi

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64|amd64)
        XRAY_ARCH="64"
        ;;
    aarch64|arm64)
        XRAY_ARCH="arm64-v8a"
        ;;
    armv7l|armv7)
        XRAY_ARCH="arm32-v7a"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Check required commands
for cmd in curl tar uuidgen; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Missing command: $cmd"
        exit 1
    fi
done

mkdir -p "$XRAY_DIR"

echo "[1/6] Getting latest stable Xray release..."

# GitHub API
RELEASE_JSON="$(curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/XTLS/Xray-core/releases/latest)"

VERSION="$(printf '%s' "$RELEASE_JSON" |
    grep '"tag_name"' |
    head -1 |
    sed -E 's/.*"tag_name": "([^"]+)".*/\1/')"

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not determine Xray version."
    exit 1
fi

echo "       Version: $VERSION"

# Xray release asset
URL="https://github.com/XTLS/Xray-core/releases/download/${VERSION}/Xray-linux-${XRAY_ARCH}.zip"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[2/6] Downloading Xray..."

curl -fL "$URL" -o "$TMP/xray.zip"

echo "[3/6] Installing Xray..."

rm -f "$XRAY_DIR/xray"

if command -v unzip >/dev/null 2>&1; then
    unzip -q "$TMP/xray.zip" -d "$TMP/xray"
else
    echo "ERROR: unzip is required."
    echo "Install unzip and run the installer again."
    exit 1
fi

cp "$TMP/xray/xray" "$XRAY_DIR/xray"
chmod 755 "$XRAY_DIR/xray"

echo "[4/6] Generating UUID..."

UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"

echo "[5/6] Creating Xray configuration..."

cat > "$CONFIG" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "::",
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "email": "user"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

echo
echo "Testing configuration..."
"$XRAY_DIR/xray" run -test -config "$CONFIG"

echo "[6/6] Installing homepage..."

mkdir -p "$HOME/www"

cat > "$HOME/www/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Limo — Personal Services</title>

  <style>
    * {
      box-sizing: border-box;
    }

    html, body {
      margin: 0;
      min-height: 100%;
      font-family: system-ui, -apple-system, BlinkMacSystemFont,
        "Segoe UI", sans-serif;
      background: #080a10;
      color: #f4f7ff;
    }

    body {
      display: grid;
      place-items: center;
      padding: 24px;
    }

    .card {
      width: min(720px, 100%);
      padding: 48px;
      border: 1px solid rgba(255,255,255,.10);
      border-radius: 24px;
      background: rgba(255,255,255,.035);
      box-shadow: 0 24px 80px rgba(0,0,0,.35);
      backdrop-filter: blur(18px);
    }

    .dot {
      width: 10px;
      height: 10px;
      display: inline-block;
      border-radius: 50%;
      background: #62e6a5;
      box-shadow: 0 0 18px rgba(98,230,165,.6);
      margin-right: 8px;
    }

    h1 {
      margin: 0 0 12px;
      font-size: clamp(36px, 7vw, 64px);
      letter-spacing: -2px;
    }

    p {
      color: #aeb6c8;
      line-height: 1.7;
      font-size: 17px;
    }

    .status {
      margin-top: 
