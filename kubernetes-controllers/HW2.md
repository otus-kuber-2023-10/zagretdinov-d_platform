### Тема: Kubernetes controllers. ReplicaSet, Deployment, DaemonSet.

__Подготовка:__
_Изначально должно быть установленно:_

- Kubelet, Kubectl, docker, containerd.

```
sudo mkdir -p /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install -y kubelet kubectl docker-ce docker-ce-cli containerd.io
```
- устанавливаю kind
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind 
sudo mv ./kind /usr/local/bin/
```
Отправляю созданный файл kind-config.yaml для локального кластера на сервер и запускаю.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/879932f9-7dd1-4c3e-9477-673d0a82a057)

```
sudo kind create cluster --config kind-config.yaml
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/47e3fc92-688f-4628-ad28-7e8cad236036)

В результате:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/68c91dc5-dafc-4079-9967-6eeb61fb671c)

__ReplicaSet__

___Запуск одной реплики микросервиса frontend:___
- Создаю манифест frontend-replicaset.yaml изменяю образ и отправляю его на сервер.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/760599bc-32d0-4f49-999e-0f72a6d4b2e3)

- Определяю, исправяю ошибку и применяю вновь.
  
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ccf0c8de-c110-4ff5-be6b-cb4c08ac77a9)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/9a6bd0ff-5ada-405f-b081-d17364f56871)

Ошибка в том что не было добавлено необходимое значение.

В результате:
```
kubectl get pods -l app=frontend
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/5810f7c9-5810-4d4a-bf2e-eca0911b4759)

- Повышаю количество метрик
```
kubectl scale replicaset frontend --replicas=3
kubectl get rs frontend
```

- Проверяю действительно ли восстанавливаются pod.
```
kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w
```

- Повторно применяю манифест frontend-replicaset.yaml

- Реплика вновь уменьшилась до одной.

- Для изменения добавляю цифру 3 в строку replicas в манифесте frontend-replicaset.yaml

- Применяю: