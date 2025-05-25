#!/bin/bash
# install_minio_with_env.sh - Installs MinIO with access keys and optional distributed setup on Ubuntu

set -e

# Configuration
MINIO_USER="minio-user"
MINIO_GROUP="minio-group"
MINIO_DIR="/usr/local/bin"
MINIO_DATA_DIR="/data/minio"
MINIO_SERVICE="/etc/systemd/system/minio.service"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadminsecret"
MINIO_NODES=1  # Set to >1 for distributed setup

# Create MinIO user and group
echo "Creating user, group and data directories..."
sudo groupadd -f $MINIO_GROUP
sudo useradd -M -s /sbin/nologin -g $MINIO_GROUP $MINIO_USER || true
sudo mkdir -p $MINIO_DATA_DIR
sudo chown -R $MINIO_USER:$MINIO_GROUP $MINIO_DATA_DIR

# Download MinIO binary
echo "Downloading MinIO server..."
wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
chmod +x /tmp/minio
sudo mv /tmp/minio $MINIO_DIR/minio

# Create MinIO systemd service
echo "Creating systemd service file..."
cat <<EOF | sudo tee $MINIO_SERVICE > /dev/null
[Unit]
Description=MinIO Object Storage
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target

[Service]
User=$MINIO_USER
Group=$MINIO_GROUP
Environment="MINIO_ROOT_USER=$MINIO_ACCESS_KEY"
Environment="MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY"
ExecStart=$MINIO_DIR/minio server $MINIO_DATA_DIR --console-address ":9001"
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Reload and start MinIO service
echo "Reloading and starting MinIO..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl restart minio

echo "✅ MinIO installed and configured with access key '$MINIO_ACCESS_KEY'"
echo "🌐 Access Web Console at http://<your-ip>:9001"
