## Тема: Шаблонизация манифестов Kubernetes

___Задание:___ 

- Шаблонизация манифестов приложения, установка, развертывание Helm, kustomize,  helmfile, jsonnet. Установка community Helm charts

___Цель:___ 

- научиться использовать менеджер Helm.
- научиться писать helm манифесты.
- научится управлять релизами при помощи helm.

___Выполнение:___

## Intro
Поднимаю кластер k8s. Решил развернуть кластер с помощью terraform и ansible.
Создаю папку terraform-k8s и папку ansible и добавляю в них манифесты конфиги, скрипты. расписывать установку и настройку терраформа и ансибла это займет очень много времени. В крации я расписал ниже не которые команды, а точнее это инициализация терраформа:    


cd kubernetes-templating/terraform-k8s
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

yc config list

yc iam key create --service-account-name devops --output key.json

Запуск проводится в самой  папке cd kubernetes-templating/terraform-k8s 
командой. 
```
terraform apply --auto-approve
```
В процессе создается одна мастер нода и n-количество воркеров, далее полученные ip адреса с помощью переменных добавлются в папку ансибл далее уже сам ансибл отрабатывает настройку кластера, тоесть инициализация воркеров в мастер, так же установка kubectl, kubelet, kubeadmin и прочие приложения для работы в кластере.  

Далее в принципе продолжаю согласно задания.


```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```