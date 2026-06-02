#!/bin/bash
set -e

echo "Чистая переустановка мониторинга..."

# 1. Удаляем старый релиз (если есть)
helm uninstall prometheus -n monitoring --wait || true

# 2. Ждём удаления ресурсов
sleep 10

# 3. Добавляем репо (на всякий случай)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 4. Создаём namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 5. Устанавливаем заново
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values.yaml \
  --wait --timeout 10m

echo "Мониторинг установлен!"
echo "Grafana: http://grafana.local (admin/admin123)"