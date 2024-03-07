#!/bin/bash
terraform init -upgrade
terraform validate
terraform plan -out terraform.plan

terraform apply terraform.plan

aws eks --region eu-west-3 update-kubeconfig --name projet-eks
sleep 10
kubectl apply -f metrics-components.yaml
sleep 10
helm repo add argo https://argoproj.github.io/argo-helm
sleep 10
kubectl create namespace argocd
sleep 10
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 10
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# argocd admin initial-password -n argocd
# VfPYCOlLtwMWmdRc
sleep 10
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sleep 10
helm repo add grafana https://grafana.github.io/helm-charts
sleep 10
kubectl create namespace prometheus
sleep 10
helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"
sleep 10
kubectl create namespace grafana
sleep 10
helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values grafana/grafana.yaml \
    --set service.type=LoadBalancer
