## Тема: Шаблонизация манифестов Kubernetes

___Задание:___ 

- Шаблонизация манифестов приложения, установка, развертывание Helm, kustomize,  helmfile, jsonnet. Установка community Helm charts

___Цель:___ 

- научиться использовать менеджер Helm.
- научиться писать helm манифесты.
- научится управлять релизами при помощи helm.

___Выполнение:___

## Intro
Поднимаю кластер k8s. В крации я расписал ниже не которые команды, а точнее это инициализация YC:    

```
cd kubernetes-templating
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
source "/home/damir/.bashrc"
yc config profile create devops
yc config set folder-id <>
yc init
```
Далее создаю managed kubernetes кластер в облаке YC, а так же группу узлов. Все настройки для более детального изучения буду настраивать в web итерфейсе YC.

Настроиваю kubectl на локальной машине и с помощью команд подключаюсь и проверяю.
```
yc managed-kubernetes cluster get-credentials $id-cluster --external
kubectl cluster-info
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cc2dde5d-3c5c-4d48-8906-daf2dde15992)

И проверяю так же группу узлов.
```
 yc managed-kubernetes cluster --id=$K8S_ID list-node-groups
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ddaacd32-651a-4fee-8849-6231d2df9ddc)

выставил самые минимальные значение для кластера.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/def0c7a5-9e13-493f-a04e-8521a46a1a79)


###Устанавливаем готовые Helm charts.
У себя на локальной машине с помощью команды устанавливаю helm3
```
snap install helm --classic
helm version
```
В результате получается.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7fd64ca5-bb36-4813-bea9-0521e81389fe)

### Устанавливаем готовые Helm charts
- nginx-ingress - сервис, обеспечивающий доступ к публичным ресурсам кластера
- cert-manager - сервис, позволяющий динамически генерировать Let's Encrypt сертификаты для ingress ресурсов
- harbor - хранилище артефактов общего назначения (Docker Registry), поддерживающее helm charts
- chartmuseum - специализированный репозиторий для хранения helm charts

### Памятка по использованию Helm
___Создание release:___
```
$ helm install <chart_name> --name=<release_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
```
___Обновление release:___
```
$ helm upgrade <release_name> <chart_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m
```
___Создание или обновление release:___
```
$ helm upgrade --install <release_name> <chart_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m
sh.helm.release.v1.<release_name>.v3 helm.sh/release.v1 1 5s
```
### Add helm repo

Добавляю репозиторий stable
По умолчанию в Helm 3 не установлен репозиторий stable

```
helm repo add stable https://charts.helm.sh/stable --force-update
helm repo list
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0277b176-cf4e-4ace-92e5-fe93eb031615)


### nginx-ingress
Создаю namespace и release nginx-ingress

```
kubectl create ns nginx-ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update ingress-nginx
helm upgrade --install nginx-ingress-release ingress-nginx/ingress-nginx --namespace=nginx-ingress --version="4.4.2"

```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/4e12615a-2616-4379-ac37-d2ebeb51e0c2)


Разбор используемых ключей:
• --wait - ожидать успешного окончания установки ( )
• --timeout - считать установку неуспешной по истечении указанного
времени
• --namespace - установить chart в определенный namespace (если не существует, необходимо создать)
• --version - установить определенную версию char

Результат:
```
kubectl get services -n nginx-ingress
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/f08ae4fc-7387-4091-9023-6cc3de8c087c)

Обязательно вот тут нужно проверить чтоб был один External-Ip.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/9b428b95-cd44-47e7-9928-6bc0584b6b23)

если будет их два сайт не заработает.


### cert-manager

Добавляю репозиторий, в котором хранится актуальный helm chart cert-manager и создаю namespace:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
```
Также для установки cert-manager предварительно потребуется создать в кластере некоторые CRD.
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
```
Установливаю cert-manager и проверяю:

```
helm install \
cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.11.0

kubectl get pods --namespace cert-manager
helm list --all-namespaces
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7203ba59-7d3f-4a86-9429-fc36a9c473b7)

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/74ef72e6-d8f8-4a89-8c72-c5ad4146fdf7)


### Самостоятельное задание
Для выпуска сертификатов потребуется ClusterIssuers. Создаю манифест issuer.yaml.

```
kubectl apply -f issuer.yaml
kubectl describe issuer.cert-manager.io/letsencrypt-production
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/37dd9429-faa1-4dff-83ed-5ae03bcd5b51)


### chartmuseum

Кастомизируем установку chartmuseum
• Создайте директорию kubernetes-templating/chartmuseum/ и поместите туда файл values.yaml
• Изучите оригинального файла values.yaml
• Включите:
    ◦ Создание ingress ресурса с корректным hosts.name (должен
использоваться nginx-ingress)
    ◦ Автоматическую генерацию Let's Encrypt сертификата
содержимое

https://github.com/helm/charts/tree/master/stable/chartmuseum

Вместо example.com указал EXTERNAL-IP сервиса моего nginx-ingress в формате <IP-адрес.nip.io> просмотренного командой ```kubectl --namespace nginx-ingress get services -o wide```.
```
yc vpc address list
yc vpc address update --id fl8t9c8hu06jjttb99kt --reserved
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/8853a6dc-b67d-4e64-8c0c-d80c372d12f6)

Создаю файл values.yaml для chartmuseum

Устанавливаю chartmuseum и проверяю:
```
cd ~/zagretdinov-d_platform/kubernetes-templating
kubectl create ns chartmuseum
kubectl apply -f cert-manager/acme-issuer.yaml
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm repo update chartmuseum
helm upgrade --install chartmuseum-release chartmuseum/chartmuseum  --wait \
 --namespace=chartmuseum \
  --version 3.1.0 \
  -f chartmuseum/values.yaml
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/5a6a4aed-5caa-40a6-a60b-5ce11ab38dbd)

Проверяю, что release chartmuseum установился:
Helm 3 хранит информацию в secrets:
```
helm ls -n chartmuseum
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/eabcd098-75cb-4b13-ad13-e171b89e846f)

Проверяем установку в соответствии с критериями:

Chartmuseum доступен по URL https://chartmuseum.158.160.131.111.nip.io
