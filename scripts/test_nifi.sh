#!/bin/bash
# Apache NiFi test script
# Author: Jo Van Montfort

# Configuration
NIFI_URL="http://localhost:8080/nifi-api"

# Check if NiFi is running
echo "🔍 Checking NiFi status..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${NIFI_URL}/flow/status)
if [ "$STATUS" != "200" ]; then
  echo "❌ NiFi API is not reachable at ${NIFI_URL} (HTTP $STATUS)"
  exit 1
fi
echo "✅ NiFi API is up and reachable."

# Get root process group ID
ROOT_PG=$(curl -s ${NIFI_URL}/flow/process-groups/root | jq -r '.processGroupFlow.id')
if [ -z "$ROOT_PG" ]; then
  echo "❌ Could not retrieve root process group ID."
  exit 1
fi
echo "📦 Root Process Group ID: $ROOT_PG"

# Create a simple Process Group (mock)
echo "📁 Creating test Process Group..."
curl -s -X POST "${NIFI_URL}/process-groups/${ROOT_PG}/process-groups" \
  -H 'Content-Type: application/json' \
  -d '{
    "revision": { "version": 0 },
    "component": {
      "name": "TestGroup",
      "position": { "x": 0.0, "y": 0.0 }
    }
  }' | jq

echo "✅ Test Process Group created (check UI manually at http://localhost:8080/nifi)."

