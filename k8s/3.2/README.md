# Домашнее задание к занятию «Установка Kubernetes»

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.


### Выполнение

# Задание 1.

## Подготовка на ВСЕХ нодах
```bash
1. Отключение swap
sudo swapoff -a
sudo sed -i '/^\([^#].*swap.*\)$/s/^/# /' /etc/fstab

2. Создаём файл автозагрузки модулей + сохранить
echo -e "overlay\nbr_netfilter\nip_tables\nnf_conntrack" | sudo tee /etc/modules-load.d/k8s.conf

Загружаем модули
sudo modprobe overlay
sudo modprobe br_netfilter
sudo modprobe ip_tables
sudo modprobe nf_conntrack

# Проверяем, что загрузились (если нет — скрипт остановится)
for mod in overlay br_netfilter; do
  lsmod | grep -q "^$mod" || { echo "Модуль $mod не загрузился!"; exit 1; }
done

3. Создаём файл настроек + сохранить
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

Применяем настройки прямо сейчас
sudo sysctl --system

4. Containerd (CRI)
sudo apt-get update -qq
sudo apt-get install -y -qq containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

5. Kubernetes пакеты
sudo apt-get install -y -qq apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update -qq
sudo apt-get install -y -qq kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
```

-----

## На мастер ноде
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.24.2/Documentation/kube-flannel.yml
```

![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.2/images/01.png)

## Вставьте команду в каждой воркер ноде, полученную с мастера
```bash
sudo kubeadm join 101.111.107.5:6443 --token <> --discovery-token-ca-cert-hash <>
```

![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.2/images/02.png)

-----

## Итоговая проверка
```bash
1. Все ноды Ready
kubectl get nodes -o wide

2. Все системные поды Running
kubectl get pods -n kube-system

3. etcd на мастере (требование задания)
kubectl get pods -n kube-system | grep etcd

4. Тест DNS
kubectl run test-dns --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local
```

![](https://github.com/Reqroot-pro/devops-netology/blob//main/k8s/3.2/images/02.png)

