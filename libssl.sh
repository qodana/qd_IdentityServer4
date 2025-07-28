#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://security.debian.org/debian-security/pool/updates/main/o/openssl/"
ARCH=$(dpkg --print-architecture)   # e.g., amd64, arm64

echo "Detected architecture: $ARCH"

echo "Fetching package list..."
PAGE=$(curl -s "$BASE_URL")

echo "Finding latest libssl1.1 for $ARCH..."
PACKAGE=$(echo "$PAGE" | grep -oP "libssl1\.1_[0-9][^\"']*_${ARCH}\.deb" | sort -V | tail -n 1)

if [[ -z "$PACKAGE" ]]; then
    echo "Error: No libssl1.1 package found for $ARCH."
    exit 1
fi

echo "Latest package: $PACKAGE"
URL="${BASE_URL}${PACKAGE}"
TMPFILE="/tmp/${PACKAGE}"

echo "Downloading $URL..."
curl -s -o "$TMPFILE" "$URL"

echo "Installing $TMPFILE..."
sudo dpkg -i "$TMPFILE" || sudo apt-get -f install -y

echo "Installation complete."
