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

Испольщую команды:
```
kubectl get pods
kubectl get statefulsets
kubectl get pv
kubectl get pvc
kubectl describe pv/pvc-bdef89eb-ae12-4eb8-a459-e21003d95895
```









