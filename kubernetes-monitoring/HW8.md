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
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/6e8c34dd-2735-464e-a298-3e5c78c67e3e)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/31de5afa-111c-410a-bff3-c2234c6f55be)
