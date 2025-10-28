#!/bin/bash
set -e

echo "📦 Installing Grafana Alloy..."

# Detectar arquitectura
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
esac

# Descargar Alloy
ALLOY_VERSION="v1.0.0"
DOWNLOAD_URL="https://github.com/grafana/alloy/releases/download/${ALLOY_VERSION}/alloy-linux-${ARCH}"

echo "⬇️  Downloading Alloy from $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" -o /tmp/alloy
chmod +x /tmp/alloy

echo "✅ Alloy installed successfully"
echo "🚀 Starting Alloy..."

# Ejecutar Alloy
exec /tmp/alloy run config.alloy \
  --server.http.listen-addr=0.0.0.0:12345 \
  --storage.path=/var/lib/alloy/data
