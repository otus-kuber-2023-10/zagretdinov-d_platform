## Тема: Volumes, Storages, StatefulSet.

#### Установка Установка и запуск kind

___kind___ - инструмент для запуска Kuberenetes при помощи Docker контейнеров.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d628f873-ac42-48b4-ba0c-5966c9027276)

#### Применение StatefulSet

Закомитем конфигурацию под именем minio-statefulset.yaml.

```
kubectl apply -f minio-statefulset.yaml
```

В результате применения конфигурации должно произойти следующее:

 - Запуститься под с MinIO
 - Создаться PVC
 - Динамически создаться PV на этом PVC с помощью дефолотного StorageClass

#### Применение Headless Service
Для того, чтобы наш StatefulSet был доступен изнутри кластера, создаю Headless Service
Закомитю конфигурацию под именем minio-headlessservice.yaml .

```
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-headless-service.yaml
```

#### Проверка работы MinIO

Использую команды для проверки:
```
kubectl get pods
kubectl get statefulsets
kubectl get pv
kubectl get pvc
kubectl describe pv/pvc-bdef89eb-ae12-4eb8-a459-e21003d95895
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/1898c926-b82d-4847-aafd-148a2c0c39e5)

## Задание со ⭐️
В конфигурации нашего StatefulSet данные указаны в открытом виде, что
не безопасно.
Для этого создам манифест minio-sec.yaml c зашифрованным кодом.

```
echo -n minio | base64
bWluaW8=
echo -n minio123 | base64
bWluaW8xMjM=
```

Отправляю на сервер и запускю. 










