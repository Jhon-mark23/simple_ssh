#!/bin/bash

# Must run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root: sudo bash install.sh"
  exit 1
fi

echo "=============================="
echo "  SIMPLE SSH AUTO INSTALLER"
echo "=============================="

WORKDIR="/usr/local/src/simple_ssh"
BIN_DIR="/usr/local/bin"

mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

# ==========================
# DOWNLOAD & RUN ssh.sh
# ==========================
echo "[1/3] Downloading ssh.sh..."
wget -q https://github.com/Jhon-mark23/simple_ssh/raw/refs/heads/main/ssh.sh

if [ ! -f ssh.sh ]; then
  echo "❌ Failed to download ssh.sh"
  exit 1
fi

chmod +x ssh.sh
echo "[2/3] Executing ssh.sh..."
bash ssh.sh

# ==========================
# INSTALL create_user.sh
# ==========================
echo "[3/3] Installing create_user command..."
wget -q https://github.com/Jhon-mark23/simple_ssh/raw/refs/heads/main/create_user.sh

if [ ! -f create_user.sh ]; then
  echo "❌ Failed to download create_user.sh"
  exit 1
fi

chmod +x create_user.sh
ln -sf "$WORKDIR/create_user.sh" "$BIN_DIR/create"

# ==========================
# CLEANUP
# ==========================
rm -f ssh.sh

echo "=============================="
echo " ✅ INSTALLATION COMPLETE"
echo "=============================="
echo "➡ You can now type: create"
