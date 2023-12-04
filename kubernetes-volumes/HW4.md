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

пароли отображены в манифесте.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/8ab1df39-1240-42cd-9cd3-8b701946ef0d)

Отправляю на сервер и запускю. 
Проверяю с помощью следующих команд.
```
kubectl apply -f .
kubectl describe secret minio-secrets
kubectl get secret minio-secrets -o yaml
kubectl describe statefulsets minio
```
Вывод на экран.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d6ba1db7-b84a-448c-8521-c8a607130679)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2c0de1a3-f5a3-497f-896d-16d9c7cbfc16)

### Удаление кластера
```
kind delete cluster
```


### Создание и использование PersistentVolumeClaim в PersistentVolumeClaim в Kubernetes (опционально) Kubernetes (опционально)

- Создаю PersistentVolume с именем "my-pv" и хранилищем типа "hostPath" в файле "my-pv.yaml":

В приведенном коде YAML:

- Постоянный объем (PV) определяется как my-pv
- Емкость 1 ГБ
- Режим доступа ReadWriteOnce

Контролировать и проверять можно с помощью следующих команд:
```
kubectl get pv: выводит список PV
kubectl describe pv <pv-name>: см. подробную информацию о PV
kubectl delete pv <pv-name>: удалить PV
```

- Создаю PersistentVolumeClaim с именем "my-pvc" в файле "my-pvc.yaml":

PersistentVolumeClaim — это ресурс в Kubernetes, который позволяет вам запрашивать частичную или полную мощность PV для ваших подов (подробно объясняется далее в статье). Используя PVC, вы можете запросить емкость хранения от PV, не зная подробностей этого PV.

- Cоздаю Pod с именем "my-pod" в файле "my-pod.yaml" отправляю на сервер и применяю следующие команды.

```
kubectl apply -f my-pod.yaml
kubectl exec -it my-pod -- /bin/bash
echo "Hello, Kubernetes Volumes!" > /app/data/data.txt
kubectl delete pod my-pod
```
Псоле того как удалил создаю новый Pod с тем же PVC "my-pvc" с именем new-pod.yaml отправляю на сервер, прменяю и демонстрирую результаты.

```
kubectl exec -it my-pod-2 -- /bin/bash
cat /app/data/data.txt
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/070ba9d9-c8ab-4ad0-ade3-2c0f3e184cac)

По результатам видно что после удаление и вновь созданного пода, созданный файлик с содержимым был восстановлен, данные остались не изменными.








