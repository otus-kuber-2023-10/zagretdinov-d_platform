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
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/0e1bdeea-ce2e-4ae2-a5fb-01465aece7b4)

Видим, что ничего не изменилось в части тэга образа.

Аналогичным образом шаблонизирую следующие параметры frontend chart

- Количество реплик в deployment
- Port, targetPort и NodePort в service
- Опционально - тип сервиса. Ключ NodePort должен появиться в манифесте только если тип сервиса - NodePort
- Другие параметры, которые на наш взгляд стоит шаблонизировать

Проверяю шаблонизированные чарты:
```
helm template frontend  -f frontend/values.yaml
helm upgrade --install frontend-release frontend --namespace hipster-shop -f frontend/values.yaml \
--dry-run
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/6509fa2a-8704-4469-a1b4-6f3c450a350b)

Включаю созданный чарт frontend в зависимости большого микросервисного приложения hipster-shop. Для начала, удаляю release frontend из кластера:
```
helm delete frontend-release -n hipster-shop
```
Добавляю chart frontend как зависимость в hipster-shop/Chart.yaml

```
dependencies:
  - name: frontend
    version: 0.1.0
    repository: "file://../frontend"
```

Обновляю.
```
helm dep update hipster-shop
```
В директории kubernetes-templating/hipster-shop/charts появился архив frontend-0.1.0.tgz содержащий chart frontend определенной версии и добавленный в chart hipster-shop как зависимость.

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/8d8f899a-f788-4081-8625-4ccfd4eaf66a)

```
helm ls -A
helm upgrade hipster-shop-release -n hipster-shop hipster-shop
kubectl get all -A -l app=frontend
```
Обновляю release hipster-shop и убеждаюсь, что ресурсы frontend вновь созданы

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/113cff9c-c7a3-490b-9270-2b57a1c7c4bf)

Осталось понять, как из CI-системы мы можем менять параметры helm chart, описанные в values.yaml. Для этого существует специальный ключ --set. Изменим NodePort для frontend в release, не меняя его в самом chart:
```
helm upgrade --install hipster-shop-release hipster-shop -n hipster-shop --set frontend.service.NodePort=31234
kubectl get svc -n hipster-shop -l app=frontend
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/90ce52f4-2cd8-4c1e-a375-b9cb2681aac4)

## Создаем свой helm chart | Задание со ⭐

Добавил чарт redis как зависимость в hipster-shop/Chart.yaml
```
  - name: redis
    version: 17.6.0
    repository: https://charts.bitnami.com/bitnami
```
Обновляю зависимости:

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/db470182-436c-4c15-b6ba-5b70fad12314)

## Работа с helm-secrets | Необязательное задание

Разберемся как работает плагин helm-secrets. Для этого добавим в Helm chart секрет и научимся хранить его в зашифрованном виде.
Для начало чтоб разобраться и заняться этим заданием я предварительно установлю socs так как уменя его нет для это скачаю бинарник и перемесщю его в bin.
```
wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
sudo mv sops-v3.7.3.linux.amd64 /usr/bin/sops
chmod +x /usr/bin/sops
```
__Обязательно проверить установлен ли gpg...__
Сгенерируем новый PGP ключ:
```
gpg --full-generate-key
gpg -k

```

Отвечаю на все вопросы. После этого что ключ появился:
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/4c4b2a10-71e8-47d5-9e39-05e802fa74b4)

Создаю новый файл secrets.yaml в директории ./frontend со следующим содержимым:
```
visibleKey: hiddenValue
```

И попробуем зашифровать его:
```
sops -e -i --pgp AF7EB27A743B93B5DBCFE90985F08E03D9B5CD75 frontend/secrets.yaml
```

и в результате файл secrets.yaml изменился

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/dc49ac30-881f-4b17-ac09-9012f6a56f19)

Для расшифровки можно использовать любой из инструментов:
```
# helm secrets
helm secrets decrypt ./frontend/secrets.yaml

# sops
sops -d ./frontend/secrets.yaml
```
Создадим в директории ./frontend/templates еще один файл secret.yaml. Несмотря на похожее название его предназначение будет отличаться.

```
apiVersion: v1
kind: Secret
metadata:
  name: secret
type: Opaque
data:
  visibleKey: {{ .Values.visibleKey | b64enc | quote }}
```
Теперь, если мы передадим в helm файл secrets.yaml как values файл плагин helm-secrets поймет, что его надо расшифровать, а значение ключа visibleKey подставить в соответствующий шаблон секрета. Запустим установку:
```
helm secrets upgrade --install frontend ./frontend -n hipster-shop \
 -f ./frontend/values.yaml \
 -f ./frontend/secrets.yaml
```

Проверяю, что секрет создан, и его содержимое соответствует ожиданиям:
```
kubectl get secret secret -n hipster-shop -o yaml | grep visibleKey | awk '{print $2}' | base64 -d -
hiddenValue%
```

## Kubecfg

Вынесем манифесты описывающие service и deployment микросервисов paymentservice и shippingservice из файла all-hipster-shop.yaml в директорию ./kubecfg
```
tree -L 1 kubecfg
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d573bf3c-3813-4de9-ba60-ad169d5fab22)

```
helm upgrade hipster-shop-release -n hipster-shop hipster-shop
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/cca707ef-ef93-4e7c-9014-f5af4ac61b22)

Проверяю, что микросервисы paymentservice и shippingservice исчезли из установки и магазин стал работать некорректно (при нажатии на кнопку Add to Cart)
```
kubectl get all -A -l app=paymentservice
kubectl get all -A -l app=shippingservice
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/5b95adac-671b-427f-b670-9d153f44350a)

Установим kubecfg
```
wget https://github.com/vmware-archive/kubecfg/releases/download/v0.22.0/kubecfg-linux-amd64
install kubecfg-linux-amd64 ~/bin/kubecfg
rm -f kubecfg-linux-amd64
kubecfg version
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/68a411fc-12ca-48f8-93f0-5d8b82b32896)

Kubecfg предполагает хранение манифестов в файлах формата .jsonnet и их генерацию перед установкой. Пример такого файла можно найти в официальном репозитории Напишем по аналогии свой .jsonnet файл - services.jsonnet. Для начала в файле мы должны указать libsonnet библиотеку, которую будем использовать для генерации манифестов. В домашней работе воспользуемся готовой от от bitnami Импортируем ее:

```
local kube = import "https://github.com/bitnami-labs/kube-libsonnet/raw/52ba963ca44f7a4960aeae9ee0fbee44726e481f/kube.libsonnet";
```
Общая логика задачи следующая:

 - Пишем общий для сервисов , включающий описание service и deployment  
 - Наследуемся от него, указывая параметры для конкретных сервисов: payment-shipping.jsonnet
 
 | Рекомендуем не заглядывать в сниппеты в ссылках и попробовать самостоятельно разобраться с jsonnet В качестве подсказки можно использовать и готовый services.jsonnet , который должен выглядеть примерно следующим образом: services.jsonnet

Проверяю, что манифесты генерируются корректно:
```
kubecfg show kubecfg/services.jsonnet
```
Установка:
```
kubecfg update kubecfg/services.jsonnet --namespace hipster-shop
```

Проверяю установку:
```
kubectl get all -A -l app=paymentservice
kubectl get all -A -l app=shippingservice
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2ce7cc54-7240-4087-a822-f115b84fd591)


## Kustomize | Самостоятельное задание

Вырежу еще один микросервис из all-hipster-shop.yaml и самостоятельно займусь его kustomизацией. Реализовываю установку на два окружения - hipster-shop (namespace hipster-shop ) и hipster-shop-prod (namespace hip-shop-prod ) из одних манифестов deployment и service Окружения должны отличаться:

- Набором labels во всех манифестах
- Префиксом названий ресурсов
- Image Tag, Memory Limits, Replicas

kubectl apply -k ./kustomize/overrides/dev
kubectl apply -k ./kustomize/overrides/prod

