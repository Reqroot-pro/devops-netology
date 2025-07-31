#!/bin/bash

set -e

# Установка Docker, если не установлен
if ! command -v docker &> /dev/null
then
    echo "Docker не найден, начинаю установку..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    newgrp docker
fi

# Установка Docker Compose через apt (docker-compose-plugin)
if ! docker compose version &> /dev/null
then
    echo "Docker Compose не найден, начинаю установку..."
    sudo apt update
    sudo apt install -y docker-compose-plugin
fi

# Проверяем, что docker compose работает
if ! docker compose version &> /dev/null
then
    echo "Ошибка: docker compose не установлен или не работает"
    exit 1
fi

# Клонируем fork
REPO_URL="https://github.com/Reqroot-pro/shvirtd-example-python.git"
TARGET_DIR="/opt/shvirtd-example-python"

if [ -d "$TARGET_DIR" ]; then
    echo "Папка $TARGET_DIR уже существует, обновляю репозиторий..."
    cd "$TARGET_DIR"
    git pull origin main
else
    echo "Клонирую репозиторий в $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# Запускаем проект через Docker Compose
docker compose down -v || true
docker compose build
docker compose up -d

echo "Проект запущен. Проверьте работу на http://158.160.170.68:8090"

