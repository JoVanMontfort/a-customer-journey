## 🧱 1. Prerequisites on Each Node
Install the same version of MinIO and configure directories consistently across all nodes.

### ✅ Steps (repeat on all nodes):
```bash
# Create a MinIO user (if not yet created)
sudo groupadd -f minio
sudo useradd -r -s /sbin/nologin -g minio minio

# Create a data directory
sudo mkdir -p /mnt/data1
sudo chown minio:minio /mnt/data1

# Download and install MinIO
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/
```
## ⚙️ 2. Shared Distributed Startup Command
Choose 4+ nodes. Each should be accessible via hostname or IP by the others.
### Example (4 nodes):
Let's say your nodes are:
* **node1 → 192.168.1.101**
* **node2 → 192.168.1.102**
* **node3 → 192.168.1.103**
* **node4 → 192.168.1.104**

Each should run the same MinIO startup command with access to the following cluster layout:

```bash
export MINIO_ROOT_USER="minioadmin"
export MINIO_ROOT_PASSWORD="minioadminsecret"

minio server \
http://192.168.1.101/mnt/data1 \
http://192.168.1.102/mnt/data1 \
http://192.168.1.103/mnt/data1 \
http://192.168.1.104/mnt/data1 \
--console-address ":9001"

✅ Important: All IPs must be accessible over port 9000 and have the same folder structure.
```

## 🔁 3. Systemd Setup on Each Node (Optional)
If you'd like MinIO to start on boot, create a systemd unit on each node:

```ini
# /etc/systemd/system/minio.service

[Unit]
Description=MinIO Distributed Object Storage
After=network.target

[Service]
User=minio
Group=minio
Environment="MINIO_ROOT_USER=minioadmin"
Environment="MINIO_ROOT_PASSWORD=minioadminsecret"
ExecStart=/usr/local/bin/minio server \\
http://192.168.1.101/mnt/data1 \\
http://192.168.1.102/mnt/data1 \\
http://192.168.1.103/mnt/data1 \\
http://192.168.1.104/mnt/data1 \\
--console-address ":9001"
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio
```
## 🌐 Accessing the Web Console
Once the cluster is up:
- Visit **http://<any-node-ip>:9001**
- Login with **minioadmin / minioadminsecret**

## ✅ Notes
- Requires at least 4 nodes or 4 drives for distributed mode.
- If you're on a cloud provider, make sure to **open ports 9000 and 9001** in the firewall.
- Use DNS or hostnames instead of IPs for more resilience.
