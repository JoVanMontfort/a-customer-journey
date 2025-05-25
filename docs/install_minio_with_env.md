## 🔐 Features Included

- Custom access credentials via environment variables:
  - MINIO_ROOT_USER = minioadmin
  - MINIO_ROOT_PASSWORD = minioadminsecret
- Systemd service for auto-start
- Ready for further extension to a distributed MinIO setup

## 🚀 How to Use

1. Upload the script to your Ubuntu server.
2. Make it executable:
```bash
chmod +x install_minio_with_env.sh
```
3. Run it with sudo:
```bash
sudo ./install_minio_with_env.sh
```
4. Access the web console at:
```cpp
http://<your-server-ip>:9001
```
(Use the minioadmin / minioadminsecret credentials unless you modify the script.)
