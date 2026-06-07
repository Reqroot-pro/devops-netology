#!/bin/bash
set -e

echo "Полный деплой проекта"

# 1. Мониторинг
echo "[1/2] Установка мониторинга"
bash monitoring/install.sh

# 2. Приложение
echo "[2/2] Деплой приложения"
kubectl apply -f app/deployment.yaml
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