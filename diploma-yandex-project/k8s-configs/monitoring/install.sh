#!/bin/bash
set -e

echo "📦 Установка kube-prometheus-stack..."

# Добавляем репозиторий
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создаём namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Устанавливаем стек
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values.yaml \
  --wait --timeout 10m

echo "✅ Мониторинг установлен!"
echo "🌐 Grafana: http://grafana.local (admin/admin123)"