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

Создал и запушил в docker hub.

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

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/6d012370-64a7-4064-9ede-0117b17cdb22)


Отлично работает...

__Создаю и применяю манифесты nginx-exporter-deployment.yaml и nginx-exporter-service.yaml__

```
kubectl apply -f nginx-exporter-deployment.yaml
kubectl apply -f nginx-exporter-service.yaml
```

__Устанавливаю оператор prometheus и деплою__

```
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -
kubectl wait --for=condition=Ready pods -l  app.kubernetes.io/name=prometheus-operator -n default
```

__Деплоим prometheus__

```
kubectl apply -f servicemonitor.yaml
kubectl apply -f prometheus-deployment.yaml
```


![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/6b960cff-abfa-4cdb-ae04-22cb54aaa2b7)


Проверяю ```kubectl get pods```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7c01f8cc-2978-4c1f-8759-ee38f1f0b9e7)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b4135246-8ae5-4488-bf8e-4895f8afe9cf)

__Деплою Grafana__

```
kubectl apply -f grafana.yaml
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2378f689-e09e-4e4e-bb8f-6e116f76a226)

Для первого входа admin:admin дальше создается новый пароль.

В UI Grafana добавил Data Source http://prometheus-operated:9090

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/23d5ea11-83a7-4493-97ab-91c1c0758311)

Загружаю дашбоарт eg. [click here](https://grafana.com/grafana/dashboards/12708-nginx/)

