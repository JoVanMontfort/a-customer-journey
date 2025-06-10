#!/bin/bash

# Configuration
NIFI_HOST="localhost"
NIFI_PORT="8080"
S3_SERVICE_NAME="MyS3ConnectionService"
ACCESS_KEY="minioadmin"             # Default MinIO credentials
SECRET_KEY="minioadmin"             # Default MinIO credentials
ENDPOINT_URL="http://localhost:9000" # MinIO default endpoint
REGION="us-east-1"                  # Required field (even for MinIO)

# Check if running as root (required for NiFi operations)
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root or use sudo"
  exit 1
fi

# Verify NiFi is running
if ! systemctl is-active --quiet nifi; then
  echo "⚠️ NiFi is not running. Attempting to start..."
  sudo systemctl start nifi || { echo "❌ Failed to start NiFi"; exit 1; }
  sleep 30 # Wait for NiFi to fully initialize
fi

# Get Root Process Group ID
echo "🔍 Getting Process Group ID..."
PG_ID=$(curl -s "http://${NIFI_HOST}:${NIFI_PORT}/nifi-api/flow/process-groups/root" | jq -r .processGroupFlow.id)

if [ -z "$PG_ID" ]; then
  echo "❌ Failed to get Process Group ID"
  echo "ℹ️ Check if NiFi is accessible at http://${NIFI_HOST}:${NIFI_PORT}/nifi"
  exit 1
fi

# Create S3 Connection Service
echo "🛠️ Creating S3 Connection Service..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  "http://${NIFI_HOST}:${NIFI_PORT}/nifi-api/flow/process-groups/${PG_ID}/controller-services" \
  -H "Content-Type: application/json" \
  -d '{
    "revision": {"version": 0},
    "component": {
      "name": "'"${S3_SERVICE_NAME}"'",
      "type": "org.apache.nifi.aws.s3.StandardS3ConnectionService",
      "properties": {
        "Access Key": "'"${ACCESS_KEY}"'",
        "Secret Key": "'"${SECRET_KEY}"'",
        "Endpoint URL": "'"${ENDPOINT_URL}"'",
        "Region": "'"${REGION}"'"
      }
    }
  }')

# Verify creation
if [ "$RESPONSE" -eq 201 ]; then
  echo "✅ Successfully created S3 Connection Service"
  echo "ℹ️ You can verify in NiFi UI: http://${NIFI_HOST}:${NIFI_PORT}/nifi"
else
  echo "❌ Failed to create service (HTTP ${RESPONSE})"
  echo "ℹ️ Common issues:"
  echo "   - NiFi not fully initialized (wait 30-60 seconds)"
  echo "   - Incorrect credentials or endpoint"
  echo "   - Missing AWS NAR file in /opt/nifi/lib/"
  exit 1
fi