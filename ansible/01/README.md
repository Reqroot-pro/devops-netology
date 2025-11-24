# Ansible Playbook: DevOps Netology Project

Этот Ansible playbook разворачивает и настраивает три основных компонента на серверах:  

1. **ClickHouse** — установка сервера и клиента, добавление репозитория, GPG ключа, настройка systemd.  
2. **Lighthouse** — установка Nginx, клонирование репозитория LightHouse, настройка конфигурации сайта и прав.  
3. **Vector** — установка Vector из официального .deb пакета, настройка systemd-сервиса.

---

## Роли

### 1. ClickHouse

- **Что делает:**
  - Обновляет apt-кэш
  - Устанавливает необходимые пакеты (`apt-transport-https`, `curl`, `gnupg`)
  - Добавляет GPG ключ ClickHouse
  - Определяет архитектуру системы
  - Добавляет репозиторий ClickHouse
  - Устанавливает `clickhouse-server` и `clickhouse-client`
  - Запускает и включает сервис

- **Handlers:**
  - `Convert ClickHouse key to gpg format` — конвертирует ключ, если скачан новый

- **Переменные:**  
  - Внутри роли начинаются с `clickhouse_`.  

---

### 2. Lighthouse

- **Что делает:**
  - Обновляет apt-кэш
  - Устанавливает Nginx
  - Создает директорию `/var/www/lighthouse`
  - Клонирует репозиторий [VKCOM/lighthouse](https://github.com/VKCOM/lighthouse.git)
  - Исправляет права на директорию после клонирования/обновления
  - Разворачивает конфигурацию Nginx через шаблон `nginx_lighthouse.conf.j2`
  - Включает/отключает сайты в Nginx
  - Запускает и включает Nginx

- **Handlers:**
  - `Reload Nginx` — перезагружает сервис при изменении конфигурации

- **Переменные:**  
  - Нет внешних параметров, можно добавить переменные пути и ветки репозитория при необходимости

---

### 3. Vector

- **Что делает:**
  - Устанавливает необходимые пакеты (`ca-certificates`, `curl`)
  - Определяет архитектуру системы
  - Скачивает официальную .deb сборку Vector для архитектуры
  - Устанавливает Vector через `apt` (`dpkg`)
  - Запускает и включает сервис Vector

- **Handlers:**
  - В роли Vector нет отдельных handlers  

- **Переменные:**  
  - `vector_arch` — архитектура системы  
  - Можно добавить путь к пакету и имя сервиса при необходимости  

---

## Теги

- `clickhouse` — установка и настройка ClickHouse  
- `lighthouse` — установка и настройка Lighthouse/Nginx  
- `vector` — установка и настройка Vector  

---

## Использование

```bash
# Выполнить весь playbook
ansible-playbook site.yml -i inventory.yml

# Выполнить только одну роль по тегу
ansible-playbook site.yml -i inventory.yml --tags clickhouse
ansible-playbook site.yml -i inventory.yml --tags lighthouse
ansible-playbook site.yml -i inventory.yml --tags vector




## Скрины

![ссылка на скриншот](https://github.com/Reqroot-pro/devops-netology/tree/main/ansible/01/images/01.png)


## Tag git
https://github.com/Reqroot-pro/devops-netology/releases/tag/08-ansible-03-yandex