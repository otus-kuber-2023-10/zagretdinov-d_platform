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
[1] Re-initialize this profile 'devops' with new settings
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.

Please choose folder to use:

Do you want to configure a default Compute zone? [Y/n] y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
```

Далее создаю managed kubernetes кластер в облаке YC, а так же группу узлов. Все настройки для более детального изучения буду настраивать в web итерфейсе YC.

Настроиваю kubectl на локальной машине и с помощью команд подключаюсь и проверяю.
```
yc managed-kubernetes cluster get-credentials devops-cluster --external
kubectl cluster-info
```
И проверяю так же группу узлов.
```
 yc managed-kubernetes cluster --id=$K8S_ID list-node-groups
```
выставил самые минимальные значение для кластера.


###Устанавливаем готовые Helm charts.
У себя на локальной машине с помощью команды устанавливаю helm3
```
snap install helm --classic
helm version
```
В результате получается.

### Устанавливаем готовые Helm charts
- nginx-ingress - сервис, обеспечивающий доступ к публичным ресурсам кластера
- cert-manager - сервис, позволяющий динамически генерировать Let's Encrypt сертификаты для ingress ресурсов
- harbor - хранилище артефактов общего назначения (Docker Registry), поддерживающее helm charts


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

### nginx-ingress
Создаю namespace и release nginx-ingress

```
kubectl create ns nginx-ingress
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=ingress-nginx --create-namespace
```

Разбор используемых ключей:
• --wait - ожидать успешного окончания установки ( )
• --timeout - считать установку неуспешной по истечении указанного
времени
• --namespace - установить chart в определенный namespace (если не существует, необходимо создать)
• --version - установить определенную версию char

Результат:

### cert-manager

Добавляю репозиторий, в котором хранится актуальный helm chart cert-manager и создаю namespace:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
```
Также для установки cert-manager предварительно потребуется создать в кластере некоторые CRD.
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml
```
Установливаю cert-manager и проверяю:

```
helm upgrade --install cert-manager jetstack/cert-manager --wait \
--namespace=cert-manager \
--version=1.13.1
kubectl get pods --namespace cert-manager
```
### Самостоятельное задание
Для выпуска сертификатов потребуtтся ClusterIssuers. Создаю манифесты staging и production окружений.

```
kubectl apply -f prod.yaml
kubectl apply -f stage.yaml
kubectl describe clusterissuers -n cert-manager
helm list --all-namespaces
kubectl --namespace nginx-ingress get services -o wide
```

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

Устанавливаю chartmuseum и проверяю:
```
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm repo update
helm repo list
cd ~/zagretdinov-d_platform/kubernetes-templating/chartmuseum
kubectl create ns chartmuseum
helm install chartmuseum chartmuseum/chartmuseum --wait \
--namespace=chartmuseum \
--version 3.1.0 \
-f values.yaml
helm ls -n chartmuseum
```

https://chartmuseum.158.160.135.13.nip.io
