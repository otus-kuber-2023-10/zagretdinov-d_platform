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

__Вопрос для самопроверки:__

1. Почему следующая конфигурация валидна, но не имеет смысла?
из самого нахождения самого grep всегда возвращается 0.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/3e97b5a4-c02f-49a6-95f0-54bbff28e84e)

Проваливаюсь в миникуб и выполняю команды.
```
minikube ssh
ps aux | grep my_web_server_process
echo $?
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/61340743-624e-42a5-b949-bdf1d2f58360)

2. Бывают ли ситуации, когда она все-таки имеет смысл?
Имеет смысл, проводится простая проверка - запущен ли процесс или нет
```
ps aux | grep my_web_server_process | grep -v grep
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/f6f88773-54a8-4f7a-ba53-0b9544509d97)

информацией ознакомился тут.

 https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes


#### Создание Deployment

_Скорее всего, в процессе изменения конфигурации Pod, вы столкнулись с  неудобством  обновления  конфигурации  пода  через kubectl  (и  уже нашли ключик --force). В  любом  случае,  для  управления  несколькими  однотипными  подамитакой способ не очень подходит. Создадим Deployment, который упростит обновление конфигурации пода и управление группами подов._

Создаю файл web-deploy.yaml в папке kubernetes-networks с содержимым и отправляю на сервер. 

удаляю старый под и деплою новый проверяю что получилось
```
kubectl delete pod/web --grace-period=0 --force
kubectl apply -f web-deploy.yaml
kubectl describe deployment web
```
В результате:

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e78798bd-dddc-497b-aba4-4e45a9f4bb71)

Согласно исправлению ReadinessProbe на
- Увеличение число реплик до 3 (replicas: 3)
- Исправления порта в readinessProbe на порт 8000

применяю манифест:


#### Deployment | Самостоятельная работа

Проверяю состояние

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/5e0d69dc-4534-4318-988a-29d713f19bc1)

Добавляю в манифест (web-deploy.yaml) блок strategy

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/8c4a14d9-8cd8-4436-a58f-e6f72b119add)

Попробуем разные варианты деплоя с крайними значениями maxSurge и maxUnavailable (оба 0, оба 100%, 0 и 100%)

- оба 0
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/1d9f41cc-7022-4bad-908b-ea7367bacef9)

- оба 100%
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/92506645-9480-437d-bf21-4bc62529b407)


- maxUnavailable: 0 maxSurge: 100%
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/5fd8b74b-084e-447f-97a9-a2b62bfc32c9)


#### Создание Service | ClusterIP
Cоздаю манифест для сервиса в папке kubernetes-networks файл web-svc-cip.yaml с содержимым отправляю на сервер и применяю.
Подключаюсь к ВМ и проверяю.  

```
kubectl get services
minikube ssh
sudo -i
curl http://10.108.146.102/index.html
iptables --list -nv -t nat | grep 10.108.146.102
ip addr show
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/9b55637f-2c88-4c7b-839a-5ea1815d652c)


![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e792a711-dab2-4888-a593-6888f6f3644d)

![Alt text](image-1.png)

https://msazure.club/kubernetes-services-and-iptables/

#### Включение IPVS

Включаю IPVS 

При запуске нового инстанса Minikube лучше использовать ключ --extra-config и сразу указать, что мы хотим IPVS

В моём случае так как я исспользую облако где развернул инфаструктуру я буду использовать следующий вид команды.

```
kubectl proxy --address='0.0.0.0' --disable-filter=true
```
теперь перехожу по ссылке.


http://51.250.65.100:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/deployment?namespace=default


и соответственно попадаю на сам дашборт.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/57cb6386-9d8e-41f7-9ea6-a93163ac43eb)

выбираю namespace kube-system , Configs and Storage/Config Maps и добавляю параметры

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/a82f9534-33e2-4fa8-9041-49ec3a0f56fe)

Ну и другой способ выполняю команду.

```
kubectl edit configmap -n kube-system kube-proxy
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ae884bed-f95e-4c21-9368-8c290ec066fe)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/75092eff-f861-4e5a-8316-c1ab1f29618b)

Теперь удалим Pod с kube-proxy , чтобы применить новую конфигурацию (он входит в DaemonSet и будет запущен автоматически)

```
kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/8df713a5-a5e5-4764-a227-1307dbb77d56)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e9ad7d70-b94a-4b43-b758-eb3991e45d69)

Что-то поменялось, но старые цепочки на месте (хотя у них теперь 0 references) 😕 kube-proxy настроил все по-новому, но не удалил мусор Запуск kube-proxy --cleanup в нужном поде - тоже не помогает
```
kubectl --namespace kube-system exec kube-proxy-<POD> kube-proxy --cleanup
```
Полностью очищаю все правила iptables.
Создадаю в ВМ с Minikube файл /tmp/iptables.cleanup

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/4e03281b-e3cb-4aee-bdb0-77f37a3778ca)

Теперь жду (примерно 30 секунд), пока kube-proxy восстановит правила для сервисов

iptables --list -nv -t nat

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b26ebdc5-68d8-47d4-9761-6710bbc391fd)

Теперь лишние правила удалены и видны только актуальную конфигурацию.


### Работа с LoadBalancer и IngressIngress

#### Установка MetalLB

MetalLB  позволяет  запустить  внутри  кластера  L4-балансировщик,который  будет  принимать  извне  запросы  к  сервисам  и  раскидывать  ихмежду подами.
НЕТ все как показал результат все не так просто.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/a9cb7367-8c10-4d83-b6f8-8d8d85ebd5cf)

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cdf892d8-8bac-4f36-9dde-0ea20655a0b0)

Что то не так.





