#!/bin/bash

NIFI_HOME="/opt/nifi"
LIB_DIR="${NIFI_HOME}/lib"
S3_NAR_URL="https://repo1.maven.org/maven2/org/apache/nifi/nifi-aws-nar/1.28.1/nifi-aws-nar-1.28.1.nar"
NAR_NAME="nifi-aws-nar-1.28.1.nar"

# Ensure script is run with sufficient privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Make sure NiFi lib directory exists
if [ ! -d "$LIB_DIR" ]; then
  echo "ERROR: NiFi lib directory not found: $LIB_DIR"
  exit 1
fi

# Download the NAR
echo "📦 Downloading S3 NAR from Apache..."
curl -L -o "${LIB_DIR}/${NAR_NAME}" "$S3_NAR_URL"

# Set proper permissions
chmod 644 "${LIB_DIR}/${NAR_NAME}"
chown nifi:nifi "${LIB_DIR}/${NAR_NAME}" 2>/dev/null || echo "ℹ️ Chown skipped (user nifi may not exist)"

# Restart NiFi to load the new NAR
echo "🔁 Restarting NiFi..."
"${NIFI_HOME}/bin/nifi.sh" restart

echo "✅ S3 NAR installed. MinIO-compatible services will be available in the Controller Services UI."
