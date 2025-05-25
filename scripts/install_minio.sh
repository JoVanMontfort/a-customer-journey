#!/bin/bash
# install_minio.sh - Installs MinIO and configures it as a systemd service on Ubuntu

set -e

# Variables
MINIO_USER="minio-user"
MINIO_GROUP="minio-group"
MINIO_DIR="/usr/local/bin"
MINIO_DATA_DIR="/data/minio"
MINIO_SERVICE="/etc/systemd/system/minio.service"

# Download MinIO
echo "Downloading MinIO server..."
wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
chmod +x /tmp/minio
sudo mv /tmp/minio $MINIO_DIR/minio

# Create user and directories
echo "Creating user, group and data directories..."
sudo groupadd -f $MINIO_GROUP
sudo useradd -M -s /sbin/nologin -g $MINIO_GROUP $MINIO_USER || true
sudo mkdir -p $MINIO_DATA_DIR
sudo chown -R $MINIO_USER:$MINIO_GROUP $MINIO_DATA_DIR

# Create systemd service file
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
ExecStart=$MINIO_DIR/minio server $MINIO_DATA_DIR --console-address ":9001"
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the MinIO service
echo "Enabling and starting MinIO service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio

echo "✅ MinIO installed and running on ports 9000 (API) and 9001 (Console)."
