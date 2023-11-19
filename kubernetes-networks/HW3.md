### Тема: Сетевое взаимодействие Pod,взаимодействие Pod, сервисы.

#### План работы

__Работа с тестовым веб-приложением__

- Добавление проверок Pod
- Создание объекта Deployment
- Добавление сервисов в кластер (ClusterIP)\
- Включение режима балансировки IPVS

__Доступ к приложению извне кластер__

- Установка MetalLB в Layer2-режиме
- Добавление сервиса LoadBalancer
- Установка Ingress-контроллера и прокси ingress-nginx
- Создание правил Ingress

#### Добавление проверок Pod

Согласно инструкциям предудущих выполненых заранее развернул миникуб.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e88ec3be-83ce-485b-99a5-1093182277b7)

Открыл файл с описанием Pod web-pod.yml Добавил в описание пода readinessProbe скопирвал в деректорию и отправил на сервер.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/04b56567-13bc-4f75-abb5-4199cf5baf27)

Применяю под.

```
kubectl apply -f web-pod.yml
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/01c6be40-36d0-42fe-b72c-1daf0136a987)

Команда kubectl describe pod/web  проверяю список Conditions:

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/514f6d04-2dd7-45c3-98d2-46d957d7c99c)

Проверяю список событий

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/536299fc-b1c5-4c04-b2ed-e24462cd6570)

_По условиям предыдущего ДЗ вебсервер слушает порт 8000 что явилось причиной неготовности контейнера._

Добавил в манифест проверку состояния веб-сервера.


![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b582bf42-7a2a-4a4c-bed0-f158b87d32ef)

Отправил и запустил под с новой конфигурацией и проверил.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/226ee0e0-ddb7-4b32-b84e-2d1adcd3cae5)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/1cda4289-1ae3-4378-a8ff-6d63331ee429)

