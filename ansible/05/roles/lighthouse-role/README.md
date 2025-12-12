# Ansible Role: LightHouse

Роль устанавливает и настраивает **LightHouse** — веб-интерфейс для ClickHouse (https://github.com/VKCOM/lighthouse).  
Включает установку Nginx, клонирование репозитория LightHouse и развертывание nginx-конфигурации.

---

## Поддерживаемые ОС

- Ubuntu 20.04+
- Debian 10+

---

## Требования

- Интернет-доступ для клонирования репозитория VKCOM/LightHouse
- Чистая установка Nginx (роль устанавливает его сама, если нужно)

---

## Использование

### Пример playbook

```yaml
- hosts: all
  become: true
  roles:
    - lighthouse
```

---

## Переменные роли

| Переменная | Значение по умолчанию | Описание |
|-----------|------------------------|----------|
| `lighthouse_repo` | `"https://github.com/VKCOM/lighthouse.git"` | Git-репозиторий LightHouse |
| `lighthouse_path` | `"/var/www/lighthouse"` | Директория установки |
| `lighthouse_branch` | `"master"` | Ветка/версия для checkout |

---

## Что делает роль

1. Обновляет apt cache  
2. Устанавливает Nginx  
3. Создаёт директорию для LightHouse  
4. Клонирует репозиторий LightHouse в нужный каталог  
5. Исправляет владельца файлов (`www-data`)  
6. Разворачивает конфиг Nginx из шаблона  
7. Создаёт symlink в `sites-enabled`  
8. Удаляет стандартный сайт Nginx  
9. Запускает и включает сервис Nginx

---

## Шаблоны

`templates/nginx_lighthouse.conf.j2`:

```nginx
server {
    listen 80;
    server_name _;

    root /var/www/lighthouse;
    index index.html;

    access_log /var/log/nginx/lighthouse.access.log;
    error_log /var/log/nginx/lighthouse.error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

---

## Handlers

Роль **не имеет handlers**, так как управление Nginx выполняется напрямую через systemd.

---

## Пример переопределения параметров

```yaml
lighthouse_path: "/srv/lighthouse"
lighthouse_branch: "v1.0"
```

---

## Лицензия

MIT

## Автор

[Дамир Гайнуллин](https://github.com/Reqroot-pro)

