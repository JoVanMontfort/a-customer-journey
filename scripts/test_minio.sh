#!/bin/bash
# Test MinIO setup script
# Author: Jo Van Montfort

# Configuration
MINIO_HOST="172.20.10.2"
MINIO_PORT="9000"
ACCESS_KEY="minioadmin"
SECRET_KEY="minioadmin"
BUCKET_NAME="test-bucket"

# Check if mc (MinIO client) is installed
if ! command -v mc &> /dev/null; then
  echo "MinIO Client (mc) not found. Installing..."
  wget https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  sudo mv mc /usr/local/bin/
fi

# Set alias for local MinIO
mc alias set local http://${MINIO_HOST}:${MINIO_PORT} ${ACCESS_KEY} ${SECRET_KEY}

# Try listing buckets
echo "📦 Checking bucket list..."
mc ls local

# Create test bucket
echo "📁 Creating test bucket: ${BUCKET_NAME}"
mc mb local/${BUCKET_NAME} || echo "Bucket may already exist."

# Upload test file
echo "📝 Creating and uploading test file..."
echo "Hello from MinIO test at $(date)" > /tmp/minio_test.txt
mc cp /tmp/minio_test.txt local/${BUCKET_NAME}/

# Verify file exists
echo "🔍 Verifying uploaded file..."
mc ls local/${BUCKET_NAME}/

# Clean up
echo "🧹 Cleaning up test file..."
mc rm local/${BUCKET_NAME}/minio_test.txt

echo "✅ MinIO test completed successfully."
