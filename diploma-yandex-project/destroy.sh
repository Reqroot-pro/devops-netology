#!/bin/bash
set -e

echo "=== Полное удаление инфраструктуры диплома ==="

# 1. ОЧИСТКА РЕЕСТРА (синхронно, с проверкой)
echo "Шаг 1: Очистка образов в Container Registry"

REGISTRY_ID=$(yc container registry list --format json | jq -r '.[0].id')

if [ -z "$REGISTRY_ID" ] || [ "$REGISTRY_ID" == "null" ]; then
    echo "Реестр не найден, пропускаем очистку."
else
    echo "Найден реестр: $REGISTRY_ID"
    
    # Цикл: удаляем, пока реестр не станет пустым
    while true; do
        IMAGE_IDS=$(yc container image list --registry-id "$REGISTRY_ID" --format json | jq -r '.[].id' 2>/dev/null || true)
        
        if [ -z "$IMAGE_IDS" ]; then
            echo "Реестр пуст."
            break
        fi
        
        echo "Удаляем образы: $IMAGE_IDS"
        for ID in $IMAGE_IDS; do
            echo "      → $ID"
            yc container image delete --id "$ID"
        done
        
        # Небольшая пауза перед следующей проверкой
        sleep 2
    done
fi

# 2. УДАЛЕНИЕ MAIN (K8s, VPC, SA)
echo "Шаг 2: Удаление основной конфигурации (main)"
cd infrastructure/main

if [ ! -d ".terraform" ]; then
    echo "Инициализация бэкенда"
    terraform init -backend-config="bucket=tf-state-a05c709a" -backend-config="key=main/terraform.tfstate" > /dev/null 2>&1 || true
fi

terraform destroy -auto-approve
echo "Main-конфигурация удалена."

# 3. УДАЛЕНИЕ BOOTSTRAP (S3, ROOT SA)
echo "Шаг 3: Удаление начальной конфигурации (bootstrap)"
cd ../bootstrap

terraform destroy -auto-approve
echo "Bootstrap-конфигурация удалена."

echo ""
echo "=== ВСЕ РЕСУРСЫ УСПЕШНО УДАЛЕНЫ ==="