#!/bin/bash
set -e

echo "[+] Terraform provisioning..."
cd ../terraform
terraform init
terraform apply -auto-approve

echo "[+] Extracting IPs..."
MASTER_IP=$(terraform output -raw k8s_master_ip)
WORKER_IPS=$(terraform output -json k8s_worker_ips | jq -r '.[]')

echo "[+] Updating Ansible inventory..."
cat <<EOF > ../ansible/inventory.ini
[k8s-master]
$MASTER_IP

[k8s-worker]
$(echo "$WORKER_IPS")

EOF

echo "[+] Running Ansible Playbooks..."
cd ../ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini kubeadm_init.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini kubeadm_join.yml

echo "[✔] Kubernetes cluster setup complete."