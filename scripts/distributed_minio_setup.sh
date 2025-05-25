#!/bin/bash
# distributed_minio_setup.sh - Configures MinIO in distributed mode (4 nodes) on a single Ubuntu host with separate directories for simulation

set -e

# Config
MINIO_USER="minio-user"
MINIO_GROUP="minio-group"
MINIO_DIR="/usr/local/bin"
MINIO_BASE_DATA="/data/minio"
MINIO_SERVICE="/etc/systemd/system/minio.service"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadminsecret"

# Number of simulated nodes/disks
NODE_COUNT=4

# Download MinIO binary
echo "Downloading MinIO server..."
wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
chmod +x /tmp/minio
sudo mv /tmp/minio $MINIO_DIR/minio

# Create MinIO user/group
echo "Creating user/group and data directories..."
sudo groupadd -f $MINIO_GROUP
sudo useradd -M -s /sbin/nologin -g $MINIO_GROUP $MINIO_USER || true

# Create multiple data directories
DATA_DIRS=""
for i in $(seq 1 $NODE_COUNT); do
    DIR="${MINIO_BASE_DATA}${i}"
    sudo mkdir -p $DIR
    sudo chown -R $MINIO_USER:$MINIO_GROUP $DIR
    DATA_DIRS="$DATA_DIRS http://127.0.0.1:9000$DIR"
done

# Create systemd service file
echo "Creating systemd service file..."
cat <<EOF | sudo tee $MINIO_SERVICE > /dev/null
[Unit]
Description=Distributed MinIO Object Storage
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target

[Service]
User=$MINIO_USER
Group=$MINIO_GROUP
Environment="MINIO_ROOT_USER=$MINIO_ACCESS_KEY"
Environment="MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY"
ExecStart=$MINIO_DIR/minio server --console-address ":9001" $DATA_DIRS
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable and start MinIO
echo "Starting distributed MinIO service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl restart minio

echo "✅ Distributed MinIO service started with $NODE_COUNT nodes."
echo "🔐 Access Key: $MINIO_ACCESS_KEY"
echo "🌐 Web UI: http://<your-ip>:9001"
