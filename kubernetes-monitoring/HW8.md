### Тема: Мониторинг сервиса вкластере k8s.
#### План работы

__4 варианта сложности на выбор:__

- Поставить все руками (I am death incarnate!). 
- Поставить prometheus-operator через kubectl apply из офф. репозитория(Bring`em on!)
- Поставить при помощи helm2 (Don`t hurt me!) 
- Поставить при помощи helm3 (Can i play, daddy?).

__Собираю образа Nginx__
Создаю кастомный  образ  nginx из предыдущего ДЗ. Раннее был запушен в docker hub и прописан в манифест web-deployment.yaml.
```
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
kubectl port-forward --address 0.0.0.0 svc/web 8000:80
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2f74e84e-e4f6-4742-b729-fdb78c9541b3)

__прокидываю порт и проверяю__

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ec203a9d-0c6a-42db-ab35-c8ef52c98492)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0f4f21f8-b637-4d6b-bfdb-c1e5097fbe31)

Отлично работает...


![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/31de5afa-111c-410a-bff3-c2234c6f55be)
