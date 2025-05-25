#!/bin/bash
# distributed_minio_node_setup.sh
# Setup script to configure a MinIO distributed node on Ubuntu

set -e

### Configuration ###
MINIO_USER="minio"
MINIO_GROUP="minio"
MINIO_BIN="/usr/local/bin/minio"
MINIO_DATA="/mnt/data1"
MINIO_SERVICE="/etc/systemd/system/minio.service"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadminsecret"

# Replace with actual node IPs or DNS
MINIO_CLUSTER_NODES=(
  "http://192.168.1.101/mnt/data1"
  "http://192.168.1.102/mnt/data1"
  "http://192.168.1.103/mnt/data1"
  "http://192.168.1.104/mnt/data1"
)

### Setup User and Directory ###
echo "Creating user and directory..."
sudo groupadd -f $MINIO_GROUP
sudo useradd -r -s /sbin/nologin -g $MINIO_GROUP $MINIO_USER || true
sudo mkdir -p $MINIO_DATA
sudo chown -R $MINIO_USER:$MINIO_GROUP $MINIO_DATA

### Install MinIO ###
if [ ! -f "$MINIO_BIN" ]; then
  echo "Installing MinIO..."
  wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
  chmod +x /tmp/minio
  sudo mv /tmp/minio $MINIO_BIN
fi

### Create Systemd Service ###
echo "Creating systemd service..."
NODE_ARGS="${MINIO_CLUSTER_NODES[*]}"
cat <<EOF | sudo tee $MINIO_SERVICE > /dev/null
[Unit]
Description=Distributed MinIO Object Storage
After=network.target

[Service]
User=$MINIO_USER
Group=$MINIO_GROUP
Environment="MINIO_ROOT_USER=$MINIO_ACCESS_KEY"
Environment="MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY"
ExecStart=$MINIO_BIN server ${NODE_ARGS} --console-address ":9001"
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

### Enable and Start MinIO ###
echo "Starting MinIO service..."
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio

echo "✅ MinIO distributed node setup complete."
echo "🌐 Web Console: http://<this-node-ip>:9001"
