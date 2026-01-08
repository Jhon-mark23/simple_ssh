#!/bin/bash

clear
echo "==================================="
echo "   MARCSCRIPT SSH VPN USER MAKER"
echo "==================================="

read -p "Username : " USER
read -p "Password : " PASS
read -p "Expire (days) : " DAYS

# Check if user exists
if id "$USER" &>/dev/null; then
  echo "❌ User already exists!"
  exit 1
fi

# Create user
useradd -m -s /bin/bash "$USER"
echo "$USER:$PASS" | chpasswd

# Set expiration
EXPIRE_DATE=$(date -d "$DAYS days" +"%Y-%m-%d")
chage -E "$EXPIRE_DATE" "$USER"

clear
echo "==================================="
echo "   ✅ SSH VPN ACCOUNT CREATED"
echo "==================================="
echo " Username : $USER"
echo " Password : $PASS"
echo " Expires  : $EXPIRE_DATE"
echo "-----------------------------------"
echo " SSH DIRECT  : Port 22 / 80"
echo " SSH SSL     : Port 443"
echo " SSH WS      : Port 8080"
echo "==================================="
