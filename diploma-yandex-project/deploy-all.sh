#!/bin/bash
set -e

echo "Полный деплой проекта"

# 1. Ingress-контроллер
echo "Установка ingress-nginx"
bash k8s-configs/ingress/install.sh

# 2. Мониторинг
echo "Установка мониторинга"
bash k8s-configs/monitoring/install.sh

# 3. Приложение
echo "Деплой приложения"
kubectl apply -f k8s-configs/app/deployment.yaml
kubectl wait --for=condition=ready pod -l app=my-app -n app --timeout=120s

echo ""
echo "ВСЁ ГОТОВО!"
echo ""
echo "Ссылки (добавить в /etc/hosts):"
echo "$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}') app.local grafana.local"
echo ""
echo "Приложение: http://app.local"
echo "Grafana:    http://grafana.local (admin/admin123)"