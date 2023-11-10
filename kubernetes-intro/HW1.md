### Тема: Настройка локального окружения. Запуск окружения. Запуск первого контейнера. Работа с kubectl.

_Установка и настройка была проведена с помощью Ancible, то есть были нарезаны плэйбуки. Развернута в облаке система Ubuntu v22 с чем и работал Ancible c моей рабочей локальной машины_  

__Установка kubectl__
    Для установки написан Bash скрипт и команды размещены в install_kubectl.sh и запускает Ancible плэйбук deploy.yml  и в дальнейшем все установки проходят на удаленной машине. Тут же и настраивается автодополнение.

__Установка Minikube__
   Аналогично установки kubectl только скрипт install_minikube.sh

__Установка Docker__
   Устанавливаю докер чтоб разнообразить как то установку, задачи, команды нарезал в самом плэйбуке, уже не прибигая к дополнительным скриптам. Все таски отрабатывает плэйбук deploy.yml
    #### и в результате:
       ![2023-11-09_01-26](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/3034fc1b-2323-4d33-894f-7dab51aeb26f)

__Запуск Minikube__
    Команду sudo usermod -aG docker $USER && newgrp docker я добавил раннее 
    в скрипт. Я зашел уже в саму машину и запустил minikube start --driver=docker и в результате все успешно запустилось.
       ![2023-11-09_01-30](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0637e11d-1ace-49bb-9831-2ff697bc333c)

   #### Проверяю:
![2023-11-09_01-32](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/552aed2c-aab7-41e5-8a26-58c9d281ba1c)
![2023-11-09_01-33](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7ea887b9-38aa-45ad-819c-522dfa164062)

__Kubernetes Dashboard__
Решил для поробовать установить и подключиться к дашборду кубернетиса. Что получилось:

развертываю по умолчанию

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`

и теперь чтоб запустить и проверить по быстрому, а так как я все настраиваю в облаке мне нужна не проста ввести команду: 

`kubectl proxy`

а немного ее дополнить.

`kubectl proxy --address='0.0.0.0' --accept-hosts='^*$'`

И результате:



__Minikube__.
Убеждаюсь что все системные компоненты работают.
`minikube ssh`
`docker ps`

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/60dfe3f9-1b9d-4f95-84e7-0f82c261c89b)

  Проверяю устойчивость к отказам
  `docker rm -f $(docker ps -a -q)`

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/308f081f-920a-44d5-91c1-693360095430)

Соответственно все восстановилось.

__kubectl__
В виде pod наблюдаю в namespace kube-system:
`kubectl get pods -n kube-system`
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cfc6d4c1-df7a-4a67-a7dc-6408dc97f86d)

Проверяю устойчивость удаляя все pod с системными компонентами:
`kubectl delete pod --all -n kube-system`
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/117cf603-5ef6-42a7-b0f9-3cb3bc4f1cfd)

Теперь с помощью команд проверю.

`kubectl get componentstatuses`
`kubectl get cs`

 #### В результате:
 
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/43b3491b-b892-4a0b-adb5-c2d3141b6742)


### Задание:
Разберитесь почему все pod в namespace kube-system восстановились после удаления. Укажите причину в описании PR.

### Решение:

kubelet является службой которая занимается процессом запуска pod-ов.
Это можно просмотреть утилиткой top.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ed957210-9d4a-470e-b061-daf47ac579f7)

Если остановить то кластер не восстанавливается автоматически.

В случае восстановление кластер запускает необходимые контейнеры.

core-dns - реализован как Deployment с параметром replicas: При его удалении ReplicaSet восстанавливает его работу

kube-proxy управляется и создается Daemonset.

kube-apiserver, etcd, kube-controller-manager, kube-scheduler - запускает kubelet ноды.

### Dockerfile

Для работы с Dockerfile было выполнено:
- Подготовлены для отправки на сервер сам dockerfile и необходмые файлы согласно задания.
- Использован для отправки файло на сервер плэйбук copy_file.yml.
- Для создания и сборки контейнера использован скрипт где написаны команды для данного процесса который в действия приводит плэйбук docker_run.yml 
- Содержимое dockerfile. согласно задания файл nginx.conf, homework.html  эскпортируется в образ и работает с uid 1001. 
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/76d0477c-62f2-4988-9345-fb25d3b7aee8)
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/fd57987a-25c3-4b56-be9c-7f8ed8ff779e)

- Проверяю. Все успешно запускается по 8000 по ссылке http://158.160.101.129:8000/homework.html
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/fa7a294d-a3cd-4427-bea8-b03f4213b8bb)
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/c57ad67f-5854-4764-8b67-e295eb8a46c6)

### Манифест pod
Для создания pod web c меткой app со значением web, содержащего один контейнер с названием web.
Я свой созданный раннее собраный образ отправил на docker hub.
Для этого были применены команды.
Тоесть изменил свой образ и запушил.
 `docker tag app/web:latest zagretdinov/web:latest`
  `docker push zagretdinov/web:latest`
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b01f9687-99f5-44c0-a948-8c8dff00a811)

Помещаю манифест web-pod.yaml в директорию kubernetes-intro и отправляю это файл на сервер.
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ee60908c-4ae9-4b57-9b57-e012bf69fe2a)

На самом сервере запускаю.
`kubectl apply -f web-pod.yaml`
Проверяю:
`kubectl get pods`
`kubectl get pod web -o yaml`
 ![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cc1f1d3b-fcf5-4c28-90fc-689c30bc09df)

 ###kubectl describe
Проверяю текущее состояние:
`kubectl describe pod web`

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cd590aab-cba4-4eac-9a7b-3f48b54c81cf)

__kubectl describe__ - хороший старт для поиска причин проблем с запуском pod.

Теперь указываю в манифесте несуществующий тег и применяю его.
`kubectl apply -f web-pod.yaml`
Наблюдаю изменения статуса.
`kubectl describe pod web`

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/409d58fc-3b1a-47db-97f1-86302e2c104b)
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b369521d-4478-4732-83f0-7c764b39f66c)

#### Далее я добавляю в манифест web-pod.yaml описание init контейнера,соответствующим требованиям что расписано в инструкции задания.

### Запуск pod
Удаляю запущенный pod
`kubectl delete pod web`
и запускаю с исправленным манифестом.
`kubectl apply -f web-pod.yaml && kubectl get pods -w`

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cf700b7f-b066-416b-ad8e-888cdce2774f)

Проверяю работу приложения.
Да кстати перед запуском приложения необходимо остановить запущенный контейнер который был применен и запущен c Dockerfile либо порт иизменить, так как они будут мешать в работе друг другу.

`kubectl port-forward --address 0.0.0.0 pod/web 8000:8000`
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/320953bf-9bab-473b-af9c-40b22cf153fb)

В итоге наблюдается вот такая интересная картинка.
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/63f554d5-93b3-4061-a03e-5cbfdf2dc3d9)

### Знакомство Hipster Shop
Все команды выполнил на удаленном сервере там где развернут кубер.
Сконировал образ frontend

`git clone https://github.com/GoogleCloudPlatform/microservices-demo.git`

Cоздал образ в папке где лежит Dockerfile и отправил его в путь в докерхаб.
`docker build . -t hipster-frontend`

`docker tag hipster-frontend:latest zagretdinov/hipster-frontend:v1`
`
`docker push zagretdinov/hipster-frontend:v1`

Запустил pod и выполнил генерацию манифеста, так как он мне выдал --dry-run устарела и выполните по другому в общем изменил как хочет система.

`kubectl run frontend --image avtandilko/hipster-frontend:v0.0.1 --restart=Never --dry-run=client -o yaml > frontend-pod.yaml`

и сработало вывод информации в файл успешно проведен.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/9ed0f69f-53e1-498b-ab8b-a16b364b23fd)


## Hipster Shop | Задание со *

Сейчас в данный момент я наблюдаю ошибку в поде frontend статус error.

Вот:
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e22935eb-18c1-45a3-aa0a-f8acf46ec43c)

Смотрю логи:
`kubectl logs frontend`
Наблюдаю следующее не хвататет некой переменной в окружающей среде.
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ea30d3cd-c775-42ee-8dca-00f481d3d6d7)

Что делаю перехожу по ссылке и копиюрую этот блок и вствляю  в созданный новый манифест frontend-pod-healthy.yaml, отправляю на сервер и запускаю

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/da663f59-6a01-464a-840a-5e38c630c254)


 Проверяю Все работает.
 
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/26e5fb79-76c1-4b57-bf34-0efae44d9a1f)

 В результате почему в статусе Error, в логах пода было panic: environment variable "PRODUCT_CATALOG_SERVICE_ADDR" not set; Соответственно был добавлен набор переменных из оригинального манифеста в frontend-pod-healthy.yaml.
