# TriggerIQ Platform Deployment (Qumulus / OpenStack)

This repo bootstraps a production-ready Kubernetes deployment of TriggerIQ using:

- Terraform to provision infrastructure on Qumulus (OpenStack)
- Ansible to install Kubernetes (kubeadm) and prepare nodes
- Helm to deploy TriggerIQ components (NiFi, MinIO, Spring Boot)

## Structure
- `terraform/kubernetes/`: Infrastructure provisioning
- `ansible/kubernetes/`: Kubeadm configuration and node setup
- `helm/triggeriq/`: TriggerIQ microservices deployment
- `scripts/`: Bootstrap helpers