#!/bin/bash
set -e

TARGET_USER=${SUDO_USER:-$USER}

echo "=== Установка Docker и Docker Compose ==="

if ! command -v docker &> /dev/null; then
    echo "Docker не найден, начинаю установку..."

    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker>
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl daemon-reload
    sudo systemctl start docker

    echo "Добавляю пользователя $TARGET_USER в группу docker"
    sudo usermod -aG docker "$TARGET_USER"

    echo "Установка завершена."
    echo "Для применения прав группы docker в текущей сессии выполните: newgrp docker"
    echo "Или выйдите из SSH и зайдите снова."
else
    echo "Docker уже установлен"
fi

# Проверка работы Docker и Docker Compose
if ! systemctl is-active --quiet docker; then
    echo "Docker service не запущен. Попробуйте запустить вручную: sudo systemctl start docker"
    exit 1
fi
echo "Docker service запущен."

if ! docker compose version &> /dev/null; then
    echo "Docker Compose не установлен или не работает."
    exit 1
fi

echo "Docker Compose работает корректно."
