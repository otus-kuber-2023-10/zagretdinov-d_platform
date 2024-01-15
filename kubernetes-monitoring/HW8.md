### Тема: Мониторинг сервиса вкластере k8s.
#### План работы

__4 варианта сложности на выбор:__

- Поставить все руками (I am death incarnate!). 
- Поставить prometheus-operator через kubectl apply из офф. репозитория(Bring`em on!)
- Поставить при помощи helm2 (Don`t hurt me!) 
- Поставить при помощи helm3 (Can i play, daddy?).

__Сборка образа Nginx__

Создаю кастомный  образ  nginx из предыдущего ДЗ. Раннее был запушен в docker hub и прописан в манифесте web-deployment.yaml.
Более подробно: скопировал папку web с предыдущего ДЗ и добавил в конфиг nginx модуль basic_status.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/6d41c66d-82b5-411d-82c3-fc308f6b85c6)

```
docker build -t zagretdinov/web:v2.0.0 .
docker push zagretdinov/web:v2.0.0
```
и добавляю в манифест.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/a70f1058-eb62-408a-b0ab-3bc70b299b7f)

применяю

```
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
kubectl port-forward --address 0.0.0.0 svc/web 8000:80
```

__прокидываю порт и проверяю__

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ec203a9d-0c6a-42db-ab35-c8ef52c98492)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0f4f21f8-b637-4d6b-bfdb-c1e5097fbe31)

Отлично работает...

__Создаю и применяю манифесты nginx-exporter-deployment.yaml и nginx-exporter-service.yaml__
```
kubectl apply -f nginx-exporter-deployment.yaml
kubectl apply -f nginx-exporter-service.yaml
```

