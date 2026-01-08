#!/bin/bash

echo "=============================="
echo "   MARCSCRIPT SSH VPN SETUP"
echo "=============================="

# Update
apt update -y && apt upgrade -y

# Install packages
apt install -y openssh-server stunnel4 nodejs npm curl

# ==========================
# SSH CONFIG
# ==========================
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
grep -q "^Port 80" /etc/ssh/sshd_config || echo "Port 80" >> /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Custom SSH banner
echo "MarcScript" > /etc/ssh/ssh_banner
grep -q "Banner" /etc/ssh/sshd_config || echo "Banner /etc/ssh/ssh_banner" >> /etc/ssh/sshd_config

systemctl restart ssh
systemctl enable ssh

# ==========================
# STUNNEL (SSL)
# ==========================
openssl req -new -x509 -days 3650 -nodes \
-subj "/CN=MarcScript" \
-out /etc/stunnel/stunnel.pem \
-keyout /etc/stunnel/stunnel.pem

cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel.pid
client = no
[ssh]
accept = 443
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
EOF

sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl restart stunnel4
systemctl enable stunnel4

# ==========================
# SSH WEBSOCKET
# ==========================
mkdir -p /opt/ws
cat > /opt/ws/ws.js <<'EOF'
const net = require('net');
const http = require('http');

const server = http.createServer();
server.on('connect', (req, socket) => {
  const ssh = net.connect(22, '127.0.0.1', () => {
    socket.write('HTTP/1.1 200 OK MarcScript\r\n\r\n');
    ssh.pipe(socket);
    socket.pipe(ssh);
  });
});

server.listen(8080);
EOF

nohup node /opt/ws/ws.js >/dev/null 2>&1 &

# ==========================
# FIREWALL
# ==========================
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 8080
ufw --force enable

echo "=============================="
echo "  SSH VPN READY"
echo " Ports: 22, 80, 443, 8080"
echo "=============================="
