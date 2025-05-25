## ✅ How to Use It

1. Download the script to your Ubuntu server

2. Make it executable:

```bash
chmod +x install_minio.sh
```

3. Run it with sudo:

```bash
sudo ./install_minio.sh
```

4. This script sets up MinIO as a systemd service, so it will start automatically on boot and can be managed using:

```bash
sudo systemctl status minio
sudo systemctl restart minio
```
