#!/bin/bash
set -e

REPO_URL="https://github.com/Reqroot-pro/shvirtd-example-python.git"
TARGET_DIR="/opt/shvirtd-example-python"

if [ -d "$TARGET_DIR" ]; then
    echo "Папка $TARGET_DIR существует, добавляю в safe.directory и обновляю репозиторий..."
    git config --global --add safe.directory "$TARGET_DIR"
    git -C "$TARGET_DIR" pull origin main
else
    echo "Клонирую репозиторий в $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
    git config --global --add safe.directory "$TARGET_DIR"
fi

cd "$TARGET_DIR"

echo "Запускаю контейнеры..."
docker compose down -v || true
docker compose build
docker compose up -d
echo "Проект запущен: http://158.160.170.68:8090"

