#!/bin/bash

# Variables
ACCOUNT_ID="811904917041"
IAM_USER="triggeriq-admin"
NODE_ROLE="triggeriq-node-role"
CLUSTER_NAME="triggeriq-cluster"
REGION="eu-west-3"

echo "Updating kubeconfig for cluster: $CLUSTER_NAME..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "Applying aws-auth ConfigMap..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::${ACCOUNT_ID}:user/${IAM_USER}
      username: ${IAM_USER}
      groups:
        - system:masters
  mapRoles: |
    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/${NODE_ROLE}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF

echo "aws-auth ConfigMap applied successfully."
