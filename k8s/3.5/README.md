# Домашнее задание к занятию Troubleshooting - Дамир Гайнуллин

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

1. Установить приложение по команде:
```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```
2. Выявить проблему и описать.
3. Исправить проблему, описать, что сделано.
4. Продемонстрировать, что проблема решена.


### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.



### Выполнение

# Задание 1.

[manifests/task-fixed](https://github.com/Reqroot-pro/devops-netology/blob/main/k8s/3.5/manifests/task-fixed.yaml)

## Ошибка 1 
Образ radial/busyboxplus:curl вызывал ошибку монтирования /etc/resolv.conf в containerd, решение заменить заменить на curlimages/curl:latest

## Исправление

```bash
# Создание неймспейсов
kubectl create namespace web
kubectl create namespace data

# Применение исправленного манифеста
kubectl apply -f task-fixed.yaml

# Перезапуск подов для применения изменений
kubectl rollout restart deployment web-consumer -n web
```

## Демонстариция решения проблем
![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.5/images/01.png)
![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.5/images/02.png)
![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.5/images/03.png)