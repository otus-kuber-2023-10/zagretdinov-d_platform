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

- Повышаю количество реплик
```
kubectl scale replicaset frontend --replicas=3
kubectl get rs frontend
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/331f8920-2358-412d-9199-e745e0f82acd)

- Проверяю действительно ли восстанавливаются pod.
```
kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/54de40e4-6380-4e89-aa13-a698b8a4a3e9)

- Повторно применяю манифест frontend-replicaset.yaml
- Реплика вновь уменьшилась до одной.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0bdbd2d9-23d6-4f6d-9953-56876f672b31)

- Для изменения добавляю цифру 3 в строку replicas в манифесте frontend-replicaset.yaml

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/4f35bd1e-f69d-43a4-aad8-7385ce364971)

- Применяю:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7a0310e1-6fac-460c-a95b-aaea1ca216a2)


__Обновление ReplicaSet__
- Добавляю на DockerHub версию образа с новым тегом v2.
- Выполню перетэгирование с версии 1 на версию 2 и отправляю.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/77acb793-bbb7-4c1d-9598-cd6776853f70)

- Изменяю версию в манивесте и применяю.  

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0a227749-45a9-4635-b28e-0969378182d6)


![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2c4b9ee9-def9-45d5-abba-77fd9cb9cb11)

Ничего не пройзошло.

- Проверяю образ в ReplicaSet:
```
kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0420106c-d14e-481b-abf7-7777dcd52dca)

- Образ на котором запущен Pod.
```
kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/c97a6564-bc59-437e-b65d-96f98b2b89b8)
  







