#!/bin/bash
set -e

# Автоматически определяем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo " Установка ingress-nginx..."

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f "$SCRIPT_DIR/nginx-values.yaml" \
  --wait --timeout 5m

echo "✅ Ingress-контроллер установлен!"
echo "🔍 Внешний IP: $(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"