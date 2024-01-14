### Тема: Мониторинг сервиса вкластере k8s.
#### План работы

__4 варианта сложности на выбор:__

- Поставить все руками (I am death incarnate!). 
- Поставить prometheus-operator через kubectl apply из офф. репозитория(Bring`em on!). 
- Поставить при помощи helm2 (Don`t hurt me!). 
- Поставить при помощи helm3 (Can i play, daddy?).

__Собираю образа Nginx__
Создаю кастомный  образ  nginx из предыдущего ДЗ. Раннее был запушен в docker hub и прописан в манифест web-deployment.yaml.
```
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
