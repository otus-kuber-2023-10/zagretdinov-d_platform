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

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/41194a31-6b4c-49be-97a9-c76771669402)

- Образ на котором запущен Pod.
```
kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/11f8e929-742b-4055-82e2-f6c06f5e31fd)

Удаляю все запущенные поды
```
sudo kubectl delete pods -l app=frontend
```
Проверяю:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cfa81d74-5f05-4604-8e89-59bb87ed4272)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/886ead22-87df-4b2a-bd96-d1ec0e711a9e)


Обновление ReplicaSet не повлекло обновление запущенных pod, так как replicaset не проверяет соответствие запущенных Podов, пока скейл не будет уменьшен до 0.

__Deployment__

- Собрал и поместил в Docker Hub образ с двумя тегами v1 и v2;

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/bdb23a57-a2cc-43f6-b5ed-aa3164bc93d0)

- Создаю валидный манифест paymentservice-replicaset.yaml с тремя репликами, разворачивающими из образа версии v0.0.1.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/67b95483-68e1-48c5-b407-4f480615952a)

- Копирую содержимое файла paymentservice-replicaset.yaml в файл paymentservice-deployment.yaml изменяю поле kind с ReplicaSet на Deployment.
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/362dff76-e03b-4fbd-9f5f-d4d168ac6e0b)

Применяю и проверяю.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0033d698-7c82-4246-a49e-e288e96fa35b)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ae8ff6e7-eb6b-459c-8d0e-7b0801e8dc7c)

- обновляю наш Deployment на версию образа v2
  ```
  kubectl apply -f paymentservice-deployment.yaml | kubectl get pods -l app=paymentservice -w
  ```
Последовательность обновления pod. По умолчанию применяется стратегия Rolling Update:
  
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7c3f126a-4018-404a-967b-1d375acb7eeb)

Убеждаюсь что:
- Все новые pod развернуты из образа v0.0.2;
- Создано два ReplicaSet:
- Один (новый) управляет тремя репликами pod с образом v0.0.2;
- Второй (старый) управляет нулем реплик pod с образом v0.0.1;

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7e3d5ad0-91b5-4523-97d1-ed09bb243f79)


##Deployment | Задание со *
Для реализации два следующих сценария развертывания использую параметры maxSurge и maxUnavailable.

В результате получаю два манифеста и отправляю их на сервер.

Манифест paymentservice-deployment-bg.yaml:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2edd178a-efa3-446d-a6de-ec7c3adbf3b4)

maxSurge равная трём это то дополнительное количество модулей которое может быть создано во вермя текущего обновления.
maxUnavailable равная нулю определяет сколько недоступных модулей во время текущего обновления. 
1. Развертывание трех новых pod;
2. Удаление трех старых pod;

Манифест paymentservice-deployment-reverse.yaml

1. Удаление одного старого pod;
2. Создание одного нового pod;

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/bdf5d5f5-0da8-4711-bfdb-dc54805e3db2)












