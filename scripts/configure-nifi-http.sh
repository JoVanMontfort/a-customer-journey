#!/bin/bash

# Path to your NiFi conf directory
NIFI_CONF_DIR="/opt/nifi/conf"
NIFI_PROPERTIES="$NIFI_CONF_DIR/nifi.properties"

# Backup original file
sudo cp "$NIFI_PROPERTIES" "$NIFI_PROPERTIES.bak"

echo "Configuring NiFi for HTTP-only access..."

# Replace or set properties
sudo sed -i -E "
s|^nifi.web.http.host=.*|nifi.web.http.host=127.0.0.1|;
s|^nifi.web.http.port=.*|nifi.web.http.port=8080|;
s|^nifi.web.http.network.interface.default=.*|nifi.web.http.network.interface.default=|;
s|^nifi.web.https.host=.*|nifi.web.https.host=|;
s|^nifi.web.https.port=.*|nifi.web.https.port=|;
s|^nifi.web.https.network.interface.default=.*|nifi.web.https.network.interface.default=|;
s|^nifi.web.https.application.protocols=.*|nifi.web.https.application.protocols=|;
s|^nifi.security.keystore=.*|nifi.security.keystore=|;
s|^nifi.security.keystoreType=.*|nifi.security.keystoreType=|;
s|^nifi.security.keystorePasswd=.*|nifi.security.keystorePasswd=|;
s|^nifi.security.truststore=.*|nifi.security.truststore=|;
s|^nifi.security.truststoreType=.*|nifi.security.truststoreType=|;
s|^nifi.security.truststorePasswd=.*|nifi.security.truststorePasswd=|;
s|^nifi.security.user.login.identity.provider=.*|nifi.security.user.login.identity.provider=|;
s|^nifi.security.user.authorizer=.*|nifi.security.user.authorizer=|;
s|^nifi.sensitive.props.key=.*|nifi.sensitive.props.key=abcdefghijklmnopqrstuvwx12345678|;
s|^nifi.flow.configuration.file=.*|nifi.flow.configuration.file=./conf/flow.json.gz|;
s|^nifi.nar.library.directory=.*|nifi.nar.library.directory=./lib|;
s|^nifi.database.repository.directory=.*|nifi.database.repository.directory=./database_repository|;
s|^nifi.flowfile.repository.directory=.*|nifi.flowfile.repository.directory=./flowfile_repository|;
s|^nifi.content.repository.directory.default=.*|nifi.content.repository.directory.default=./content_repository|;
s|^nifi.provenance.repository.directory.default=.*|nifi.provenance.repository.directory.default=./provenance_repository|;
s|^nifi.remote.input.socket.port=.*|nifi.remote.input.socket.port=|;
s|^nifi.remote.input.secure=.*|nifi.remote.input.secure=false|;
s|^nifi.remote.input.enabled=.*|nifi.remote.input.enabled=false|;
" "$NIFI_PROPERTIES"

echo "HTTP configuration complete. Backup saved as nifi.properties.bak"
