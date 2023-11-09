# zagretdinov-d_platform
zagretdinov-d Platform repository
# Homework 1
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

__Minikube__
  Убеждаюсь что все системные компоненты работают.
  _minikube ssh_
  _docker ps_

  Проверяю устойчивость к отказам
  _docker rm -f $(docker ps -a -q)_

__kubectl__
В виде pod наблюдаю в namespace kube-system:
_kubectl get pods -n kube-system_

Проверяю устойчивость удаляя все pod с системными компонентами:
_kubectl delete pod --all -n kube-system_

Теперь с помощью команд проверю.

_kubectl get componentstatuses_
_kubectl get cs_
 #### В результате:


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




