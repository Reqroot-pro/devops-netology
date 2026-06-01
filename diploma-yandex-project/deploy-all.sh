#!/bin/bash
set -e

echo "🚀 Запуск полного деплоя..."

# 1. Ingress
echo "🌐 Установка ingress-nginx..."
cd k8s-configs/ingress && bash install.sh && cd ../..

# 2. Мониторинг
echo "📊 Установка мониторинга..."
cd k8s-configs/monitoring && bash install.sh && cd ../..

# 3. Приложение
echo "🐳 Деплой приложения..."
kubectl apply -f k8s-configs/app/deployment.yaml

# 4. Ждём готовности
echo "⏳ Ожидание готовности подов..."
kubectl wait --for=condition=ready pod -l app=my-app -n app --timeout=120s

echo ""
echo "✅ ВСЁ ГОТОВО!"
echo ""
echo "🔗 Ссылки:"
echo "   Grafana: http://grafana.local (admin/admin123)"
echo "   App:     http://app.local"
echo ""
echo "🔧 Для локального тестирования добавьте в /etc/hosts:"
echo "   $(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}') grafana.local app.local"