#!/bin/bash
# Ubuntu Datalake & DevOps Extended Setup Script
# Author: JoVanMontfort | For: Project Kanban (GitHub)

set -e

### 📦 SYSTEM UPDATE & TOOLS
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip htop gnupg2 ca-certificates lsb-release apt-transport-https software-properties-common openjdk-17-jdk build-essential python3 python3-pip net-tools ufw tmux fail2ban

### 📦 INSTALL OPENJDK 17
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk

JAVA_PATH="/usr/lib/jvm/java-17-openjdk-amd64"

echo "Setting Java 17 as default..."
sudo update-alternatives --install /usr/bin/java java $JAVA_PATH/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac $JAVA_PATH/bin/javac 1
sudo update-alternatives --set java $JAVA_PATH/bin/java
sudo update-alternatives --set javac $JAVA_PATH/bin/javac

echo "Configuring JAVA_HOME in ~/.bashrc..."
if grep -q "export JAVA_HOME=" ~/.bashrc; then
   sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=$JAVA_PATH|" ~/.bashrc
else
   echo "export JAVA_HOME=$JAVA_PATH" >> ~/.bashrc
fi

if ! grep -q 'export PATH=\$JAVA_HOME/bin:\$PATH' ~/.bashrc; then
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
fi

echo "Applying environment changes..."
source ~/.bashrc

echo "Java version:"
java -version
echo "JAVA_HOME is set to: $JAVA_HOME"

### 🐘 POSTGRESQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql && sudo systemctl start postgresql

### 📦 PODMAN
sudo apt install -y podman

### 🧠 MINIO
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/
sudo useradd -r minio-user || true
sudo mkdir -p /data/minio
sudo chown -R minio-user:minio-user /data/minio

cat <<EOF | sudo tee /etc/systemd/system/minio.service
[Unit]
Description=MinIO
After=network.target

[Service]
User=minio-user
Group=minio-user
ExecStart=/usr/local/bin/minio server /data/minio --console-address :9001
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio

### 🔁 APACHE NIFI (Secure Setup)

# 🌀 NiFi Version
NIFI_VERSION=1.28.1

NIFI_DIR=/opt/nifi
# KEYSTORE_DIR=$NIFI_DIR/conf/security
# KEYSTORE_PASSWORD="nifi1234"
# KEYSTORE_PATH="$KEYSTORE_DIR/keystore.jks"
# TRUSTSTORE_PATH="$KEYSTORE_DIR/truststore.jks"
# DNAME="CN=localhost, OU=ProjectKanban, O=DevOps, L=City, S=State, C=NL"
# SENSITIVE_PROPS_KEY="changemeS3cr3tK3y"
# NIFI_USER=admin
# NIFI_PASS=admin1234

# 🚫 Remove existing NiFi installation (Optional Safety)
sudo systemctl stop nifi || true
sudo rm -rf /opt/nifi
sudo rm -f /etc/systemd/system/nifi.service
sudo userdel -r nifi 2>/dev/null || true

# 1. Download and install NiFi
wget -q https://downloads.apache.org/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.zip
unzip -o nifi-${NIFI_VERSION}-bin.zip
sudo mv -f nifi-${NIFI_VERSION} $NIFI_DIR
sudo useradd -r -s /bin/false nifi
sudo chown -R nifi:nifi $NIFI_DIR

# 2. Generate self-signed cert (safe for re-runs)
# sudo mkdir -p $KEYSTORE_DIR
# sudo chown -R nifi:nifi $KEYSTORE_DIR

# if [ -f "$KEYSTORE_PATH" ]; then
  # sudo keytool -delete -alias nifi-cert -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD 2>/dev/null
# fi

# sudo keytool -genkeypair -alias nifi-cert -keyalg RSA -keysize 2048 \
  # -dname "$DNAME" -keypass $KEYSTORE_PASSWORD -storepass $KEYSTORE_PASSWORD \
  # -keystore $KEYSTORE_PATH -validity 3650 -storetype JKS

# sudo cp -f $KEYSTORE_PATH $TRUSTSTORE_PATH
# sudo chown -R nifi:nifi $KEYSTORE_DIR

# 3. Configure nifi.properties
# sudo tee $NIFI_DIR/conf/nifi.properties > /dev/null <<EOF
# nifi.web.http.host=
# nifi.web.http.port=
# nifi.web.https.host=localhost
# nifi.web.https.port=8443

# nifi.security.keystore=$KEYSTORE_PATH
# nifi.security.keystoreType=JKS
# nifi.security.keystorePasswd=$KEYSTORE_PASSWORD

# nifi.security.truststore=$TRUSTSTORE_PATH
# nifi.security.truststoreType=JKS
# nifi.security.truststorePasswd=$KEYSTORE_PASSWORD

# nifi.security.user.login.identity.provider=single-user-provider
# nifi.security.user.authorizer=default-authorizer

# nifi.sensitive.props.key=$SENSITIVE_PROPS_KEY

# nifi.flow.configuration.file=./conf/flow.json.gz
# nifi.nar.library.directory=./lib
# nifi.web.http.host=0.0.0.0
# nifi.web.http.port=8080

# nifi.web.https.host=
# nifi.web.https.port=

# nifi.security.keystore=
# nifi.security.keystoreType=
# nifi.security.keystorePasswd=

# nifi.security.truststore=
# nifi.security.truststoreType=
# nifi.security.truststorePasswd=

# nifi.security.user.login.identity.provider=
# nifi.security.user.authorizer=

# nifi.sensitive.props.key=$(uuidgen | tr -d '-' | head -c 32)
# nifi.flow.configuration.file=./conf/flow.json.gz
# nifi.nar.library.directory=./lib

# nifi.database.repository.directory=./database_repository

# nifi.flowfile.repository.directory=./flowfile_repository
# nifi.content.repository.directory.default=./content_repository
# nifi.provenance.repository.directory.default=./provenance_repository
# EOF

# 4. Set single-user credentials
# sudo -u nifi $NIFI_DIR/bin/nifi.sh set-single-user-credentials $NIFI_USER $NIFI_PASS

# 5. Configure login-identity-providers.xml
# sudo tee $NIFI_DIR/conf/login-identity-providers.xml > /dev/null <<EOF
# <loginIdentityProviders>
  # <provider>
    # <identifier>single-user-provider</identifier>
    # <class>org.apache.nifi.authentication.single.user.SingleUserLoginIdentityProvider</class>
    # <property name="Username"></property>
    # <property name="Password"></property>
  # </provider>
# </loginIdentityProviders>
# EOF

# 6. Configure authorizers.xml (default-managed)
# sudo tee $NIFI_DIR/conf/authorizers.xml > /dev/null <<EOF
# <authorizers>
  # <authorizer>
    # <identifier>default-authorizer</identifier>
    # <class>org.apache.nifi.authorization.StandardManagedAuthorizer</class>
    # <property name="User Group Provider">file-user-group-provider</property>
    # <property name="Access Policy Provider">file-access-policy-provider</property>
  # </authorizer>

  # <userGroupProvider>
    # <identifier>file-user-group-provider</identifier>
    # <class>org.apache.nifi.authorization.FileUserGroupProvider</class>
    # <property name="Users File">./conf/users.xml</property>
    # <property name="Groups File">./conf/groups.xml</property>
  # </userGroupProvider>

  # <accessPolicyProvider>
    # <identifier>file-access-policy-provider</identifier>
    # <class>org.apache.nifi.authorization.FileAccessPolicyProvider</class>
    # <property name="User Group Provider">file-user-group-provider</property>
    # <property name="Authorizations File">./conf/authorizations.xml</property>
  # </accessPolicyProvider>
# </authorizers>
# EOF

# 6. Optional: Delete any custom security config files
# sudo rm -f /opt/nifi/conf/authorizers.xml
# sudo rm -f /opt/nifi/conf/login-identity-providers.xml

# 7. Create blank flow if not exists
# sudo -u nifi touch $NIFI_DIR/conf/flow.json.gz

# 8. Systemd service setup
sudo tee /etc/systemd/system/nifi.service > /dev/null <<EOF
[Unit]
Description=Apache NiFi
After=network.target

[Service]
Type=forking
ExecStart=$NIFI_DIR/bin/nifi.sh start
ExecStop=$NIFI_DIR/bin/nifi.sh stop
User=nifi
Group=nifi
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nifi
sudo systemctl start nifi

### ☕ INTELLIJ IDEA
sudo snap install intellij-idea-community --classic

### ☸️ KUBERNETES (MicroK8s)
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

### 🔍 ELASTIC STACK
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-add-repository "deb https://artifacts.elastic.co/packages/8.x/apt stable main"
sudo apt update
sudo apt install -y elasticsearch kibana logstash
sudo systemctl enable elasticsearch && sudo systemctl start elasticsearch
sudo systemctl enable kibana && sudo systemctl start kibana
sudo systemctl enable logstash && sudo systemctl start logstash

### 🛡️ FIREWALL + FAIL2BAN
for port in 22 9000 9001 8080 5601 5432; do
  sudo ufw allow ${port}/tcp
done

sudo ufw enable
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

### 📦 MONITORING (Prometheus + Node Exporter)
sudo useradd -rs /bin/false prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar xvf prometheus-2.52.0.linux-amd64.tar.gz
sudo mv prometheus-2.52.0.linux-amd64 /etc/prometheus
sudo ln -s /etc/prometheus/prometheus /usr/local/bin/prometheus
sudo ln -s /etc/prometheus/promtool /usr/local/bin/promtool

cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/etc/prometheus/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/etc/prometheus/data

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

### 📂 BACKUPS (cron + rsync placeholder)
echo "0 3 * * * root rsync -a /data/minio /backup/minio" | sudo tee -a /etc/crontab > /dev/null
sudo mkdir -p /backup/minio
sudo chown -R root:root /backup/minio

### 🔐 SSO Integration Placeholder
echo "🔐 SSO integration (Keycloak/Auth0/OIDC) not yet configured – please configure manually as needed."

### 🔐 config ssh
sudo apt update
sudo apt install openssh-server

sudo systemctl enable ssh
sudo systemctl start ssh

sudo systemctl status ssh

sudo apt install net-tools
ifconfig

echo "✅ Volledige installatie voltooid. Log opnieuw in of herstart om alle gebruikersrechten te activeren."
echo "➡️ MinIO: http://localhost:9001"
echo "➡️ NiFi: http://localhost:8080/nifi"
echo "➡️ IntelliJ: typ 'intellij-idea-community' in terminal"
echo "➡️ Kibana: http://localhost:5601"
echo "➡️ Prometheus: http://localhost:9090"
echo "➡️ PostgreSQL: port 5432"
echo "➡️ MicroK8s: gebruik 'microk8s kubectl'"
