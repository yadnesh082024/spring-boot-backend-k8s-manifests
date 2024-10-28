#!/bin/bash

# Specify the folder containing the files
folder_path="spring-boot-backend-k8s-manifests/argocd-configs/argocd-app-helm-chart"

# Get the list of files in the folder
files=$(ls $folder_path)

# Generate the workflow content
workflow_content=$(cat <<EOF
name: Configure app with argo cd

on:
  workflow_dispatch:
    inputs:
      filename:
        description: 'Select a file'
        required: true
        type: choice
        options:
EOF
)

for file in $files; do
    workflow_content+=$(cat <<EOF
          - $file
EOF
)
done

workflow_content+=$(cat <<EOF

jobs:
  deploy:
    permissions:
      actions: read
      contents: read
      id-token: write
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Azure Login action
        uses: azure/login@v2.2.0
        with:
          creds: \${{ secrets.AZURE_CREDENTIALS }}
          enable-AzPSSession: true

      - name: Set up kubelogin for non-interactive login
        uses: azure/use-kubelogin@v1.2
        with:
          kubelogin-version: 'v0.1.4'

      - name: Get K8s context
        uses: azure/aks-set-context@v4.0.1
        with:
          resource-group: \${{ secrets.RESOURCE_GROUP }}
          cluster-name: \${{ secrets.CLUSTER_NAME }}
          admin: 'false'
          use-kubelogin: 'true'

      - name: Set up Kubernetes
        uses: azure/setup-kubectl@v4.0.0
        with:
          version: 'latest'

      - name: Set up Helm
        uses: azure/setup-helm@v4.2.0
        with:
          version: 'latest'

      - name: Wait for changes to apply
        run: sleep 10

      - name: Configure application with argo cd
        run: |
          helm upgrade --install spring-app-argo-cd ./argocd-configs/argocd-app-helm-chart --namespace argocd --values=../argocd-configs/argocd-app-helm-chart/\${{ github.event.inputs.filename }}
EOF
)

# Write the workflow content to the file
echo "$workflow_content" > .github/workflows/manual-trigger.yml

echo "Workflow file generated successfully."