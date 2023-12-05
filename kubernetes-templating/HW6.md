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
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/76aae2c8-e480-49d1-b899-dd497ef9080b)


И проверяю так же группу узлов.
```
 yc managed-kubernetes cluster --id=$K8S_ID list-node-groups
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ddaacd32-651a-4fee-8849-6231d2df9ddc)

выставил самые минимальные значение для кластера.
```
yc managed-kubernetes cluster list
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/fbe63327-e9a1-43a6-b7dd-010cb09a8b45)

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

• --timeout - считать установку неуспешной по истечении указанного времени

• --namespace - установить chart в определенный namespace (если не существует, необходимо создать)

• --version - установить определенную версию char

Результат:
```
kubectl get services -n nginx-ingress
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/3556d6ee-45e8-4dfb-8e59-7f2fdde9ec5b)

Обязательно вот тут нужно проверить чтоб был один External-Ip.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b9ae675c-b265-43ea-a5f7-cbdef0d4abd2)

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
yc vpc address update --id_ip --reserved
```
Создаю файл values.yaml для chartmuseum

Устанавливаю chartmuseum и проверяю:
```
cd ~/zagretdinov-d_platform/kubernetes-templating
kubectl create ns chartmuseum
kubectl apply -f cert-manager/issuer.yaml
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

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d1235b96-31da-4fe6-a737-0a3b38c133b8)

Проверяем установку в соответствии с критериями:


### Критерий успешности установки

Chartmuseum доступен по URL https://chartmuseum.158.160.131.174.nip.io/

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d2f15c13-495d-4461-bcaf-7f81761eda0f)


## harbor

### Самостоятельное задание

Установка harbor

```
helm repo add harbor https://helm.goharbor.io
helm repo update harbor
kubectl create ns harbor
```

Правлю harbor/values.yaml в части 'ingress'
```
helm search repo harbor -l
helm search repo harbor
helm upgrade --install harbor harbor/harbor --wait --namespace=harbor --version=1.11.0 -f ./harbor/values.yaml
helm ls -n harbor
kubectl get secrets -n harbor -l owner=helm
```
в результате:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ee6e001d-e53c-402b-9dfd-c635ea4af9ee)

### Критерий успешности установки
• Harbor запущен и работает

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/4d0af947-f329-46f9-b8d6-f14d725e7412)


### Используем helmfile | Задание со ⭐

Опиcываю установку nginx-ingress, cert-manager и harbor в helmfile

- Скачиваю бинарник
```
wget https://github.com/helmfile/helmfile/releases/download/v0.150.0/helmfile_0.150.0_linux_amd64.tar.gz
```

- Раскпаковываю отправляю в папку bin удаляю архив присваиваю права:
```
tar xzvf helmfile_0.150.0_linux_amd64.tar.gz -C /usr/bin
rm -f helmfile_0.150.0_linux_amd64.tar.gz
chmod +x ~/bin/helmfile
```
устанавливаю плагин
```
helm plugin install https://github.com/databus23/helm-diff
```
Далее создаю папку values куда копирую целиком папки harbor и chartmuseum.
Запускаю манифест helmfile.yaml в папке helmfile
```
cd helmfile
helmfile apply
```

# Создаем свой helm chart

__Типичнаяжизненнаяситуация:__

•  Есть приложение, которое готово к запуску в Kubernetes
•  Есть манифесты для этого приложения,  но надо запускать его на разных окружениях сразными параметрами 

__Возможные варианты решения:__
•  Написать разные манифесты для разных окружений
•  Использовать "костыли" - sed, envsubst, etc...
•  Использовать полноценное решение для шаблонизации (helm, etc...)

Рассмотриваем третий вариант.
Использовать будем демо-приложение, hipster-shop https://github.com/GoogleCloudPlatform/microservices-demo  представляющее собой типичный набор микросервисов.

Стандартными средствами helm инициализируем структуру директории с содержимым будущего helm chart

```
helm create hipster-shop
```
Мы будем создавать chart для приложения с нуля, поэтому удалим values.yaml и содержимое templates
```
rm ./hipster-shop/values.yaml
rm -rf ./hipster-shop/templates/*
wget https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-04/05-Templating/manifests/all-hipster-shop.yaml \
-O ./hipster-shop/templates/all-hipster-shop.yaml
```
В целом, helm chart уже готов, можем попробовать установить его:
```
kubectl create ns hipster-shop
helm upgrade --install hipster-shop-release hipster-shop --namespace hipster-shop
helm ls -n hipster-shop
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/90ed5ba2-d4a2-43fb-bdb0-bd2c88cc3034)

```
kubectl get services -n hipster-shop
kubectl get nodes -o wide
kubectl get svc -A | grep NodePort
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/70db9cdd-3971-43ca-b9ab-a9681e1d990f)

Проверяю работу UI
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/69cfd33d-ebc6-4ab1-b989-8e49a3379d61)

Выносим все что связано с frontend в отдельный helm chart.

Аналогично чарту hipster-shop удаляю файл values.yaml и файлы в директории templates , создаваемые по умолчанию.
```
rm -rf frontend/templates
rm -f frontend/values.yaml
```
Выделим из файла all-hipster-shop.yaml манифесты для установки микросервиса frontend. В директории templates чарта frontend создадим файлы:

- deployment.yaml - должен содержать соответствующую часть из файла all-hipster-shop.yaml
- service.yaml - должен содержать соответствующую часть из файла allhipster-shop.yaml
- ingress.yaml - создадим самостоятельно.

Переустановили 'hipster-shop'

```
helm upgrade --install hipster-shop-release hipster-shop --namespace hipster-shop
helm ls -n hipster-shop
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d4bb5cc3-fcf1-4b06-b32d-34ce921f7e0e)

Доступ к UI пропал и таких ресурсов больше нет

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e8f3b088-ae6b-4134-a2ea-d9e91b762a73)

```
kubectl get svc -A | grep NodePort | wc -l 
```

Установим chart frontend в namespace hipster-shop и проверим что доступ к UI вновь появился:

```
helm upgrade --install frontend-release frontend --namespace hipster-shop
kubectl get svc -n hipster-shop | grep NodePort 
kubectl get ingress -A
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/97f582bc-eb9e-4d8f-942a-2b89955dc1cb)

Проверяю работу UI
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/b07697fc-d235-470f-beee-fbc7a1214573)

Создаю frontend/values.yaml, добавляю .image.tag, изменяю frontend/templates/deployment.yaml, перезапускаю обновления чарта:
```
helm upgrade --install frontend-release frontend --namespace hipster-shop -f frontend/values.yaml
kubectl describe  pods -n hipster-shop -l app=frontend | grep -i image
```




