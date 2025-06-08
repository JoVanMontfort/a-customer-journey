#!/bin/bash
# Write MinIO Client (mc) config with predefined credentials
# Author: Jo Van Montfort

# Configuration values
MINIO_HOST="172.20.10.2"
MINIO_PORT="9000"
ACCESS_KEY="minioadmin"
SECRET_KEY="minioadmin"
MC_CONFIG_DIR="${HOME}/.mc"
MC_CONFIG_FILE="${MC_CONFIG_DIR}/config.json"

# Ensure the config directory exists
mkdir -p "${MC_CONFIG_DIR}"

# Write config.json
cat > "${MC_CONFIG_FILE}" <<EOF
{
  "version": "10",
  "aliases": {
    "local": {
      "url": "http://${MINIO_HOST}:${MINIO_PORT}",
      "accessKey": "${ACCESS_KEY}",
      "secretKey": "${SECRET_KEY}",
      "api": "S3v4",
      "path": "auto"
    }
  }
}
EOF

echo "✅ MinIO Client config written to ${MC_CONFIG_FILE}"
