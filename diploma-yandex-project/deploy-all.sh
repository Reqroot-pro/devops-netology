#!/bin/bash
set -e

echo "Полный деплой проекта"

# 1. Ingress-контроллер
echo "[1/3] Установка ingress-nginx"
bash k8s-configs/ingress/install.sh

# 2. Мониторинг
echo "[2/3] Установка мониторинга"
bash k8s-configs/monitoring/install.sh

# 3. Приложение
echo "[3/3] Деплой приложения"
kubectl apply -f k8s-configs/app/deployment.yaml
kubectl wait --for=condition=ready pod -l app=my-app -n app --timeout=120s

echo ""
echo "=== ДЕПЛОЙ ЗАВЕРШЁН ==="
echo ""

if [ -n "$BALANCER_IP" ]; then
    echo "Ссылки (порт 80):"
    echo " • Приложение:  http://$BALANCER_IP/"
    echo " • Grafana:     http://$BALANCER_IP/grafana"
    echo "  (Логин: admin / Пароль: admin123)"
else
    echo "Если балансировщик ещё не получил IP:"
    echo "kubectl get svc -n ingress-nginx ingress-nginx-controller"
fi
echo ""