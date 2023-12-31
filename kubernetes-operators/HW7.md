## Тема: Операторы, Custom Resource Definitions

___Задание:___ 

Описание собственного CRD, использование open-source операторов

___Цель:___ 

- разбор что такое CRD и как их использовать
- создание собственной Custom Resource Refinition и собственный Custom Recource
- написание собственного оператора для взаимодействия с Mysql сервером в рамках кластера kubernetes.

___Выполнение:___

### Подготовка
Запускаю kubernetes кластер в minikube/создадим поддиректорию deploy
```
mkdir -p ./deploy
minikube start
```
### Что должно быть в описании MySQL
Для создания pod с MySQL оператору понадобится знать:

- Какой образ с MySQL использовать
- Какую db создать
- Какой пароль задать для доступа к MySQL

### CustomResource
Cоздаю CustomResourceDefinition

```
kubectl apply -f deploy/crd.yaml
```
Cоздаю CustomResource

```
kubectl apply -f deploy/cr.yaml
```

Ошибка: Error from server (BadRequest): error when creating "deploy/cr.yml": MySQL in version "v1" cannot be handled as a MySQL: strict decoding error: unknown field "usless_data"

Коминтируб в cr.yml: usless_data: "useless info". Применяю ...

Все манифесты лежат в директории kubernetes-operators/deploy


### Взаимодействие с объектами CR CRD..

Согласно командам все отработало.
```
kubectl get crd
kubectl get mysqls.otus.homework
kubectl describe mysqls.otus.homework mysql-instance
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/92994b3e-7fb5-4fae-88e9-e79523868569)


__Устанавливаю зависимости:__
sudo apt install python3-pip
sudo apt-get update
sudo apt install python3-pip --fix-missing
pip install kopf
pip install kubernetes
pip install jinja2

__MySQL контроллер__
Согласно методичке ДЗ в папке kubernetes-operators/build создаю файл mysqloperator.py. Для написания контроллера будет использоваться kopf и в директории  kubernetes-operators/build/templates создаю шаблоны.
- получается что-то похожее на:

```
import kopf
import yaml
import kubernetes
import time
from jinja2 import Environment, FileSystemLoader


def render_template(filename, vars_dict):
    env = Environment(loader=FileSystemLoader('./templates'))
    template = env.get_template(filename)
    yaml_manifest = template.render(vars_dict)
    json_manifest = yaml.load(yaml_manifest)
    return json_manifest


@kopf.on.create('otus.homework', 'v1', 'mysqls')
# Функция, которая будет запускаться при создании объектов тип MySQL:
def mysql_on_create(body, spec, **kwargs):
    name = body['metadata']['name']
    image = body['spec']['image']
    password = body['spec']['password']
    database = body['spec']['database']
    storage_size = body['spec']['storage_size']

    # Генерируем JSON манифесты для деплоя
    persistent_volume = render_template('mysql-pv.yml.j2',
                                        {'name': name,
                                         'storage_size': storage_size})
    persistent_volume_claim = render_template('mysql-pvc.yml.j2',
                                              {'name': name,
                                               'storage_size': storage_size})
    service = render_template('mysql-service.yml.j2', {'name': name})

    deployment = render_template('mysql-deployment.yml.j2', {
        'name': name,
        'image': image,
        'password': password,
        'database': database})

    api = kubernetes.client.CoreV1Api()
    # Создаем mysql PV:
    api.create_persistent_volume(persistent_volume)
    # Создаем mysql PVC:
    api.create_namespaced_persistent_volume_claim('default', persistent_volume_claim)
    # Создаем mysql SVC:
    api.create_namespaced_service('default', service)

    # Создаем mysql Deployment:
    api = kubernetes.client.AppsV1Api()
    api.create_namespaced_deployment('default', deployment)
```
С такой конфигурацие уже должны обрабатываться события при cоздании cr.yml, проверим, для этого из папки build:
```
kopf run mysql-operator.py
```
cr.yml был до этого применен, то вот:

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/c8103c0d-d795-495e-a233-d2b8bc6eb769)

Вопрос: почему объект создался, хотя мы создали CR, до того, как запустили контроллер?
Оператор проверяет наличе созданных CR. Объект создался автоматически для того чтобы после рестарта или удаления CustomResource оператор мог нормально функционировать.

Если сделать ```kubectl delete mysqls.otus.homework mysqlinstance ```, то CustomResource будет удален, но наш контроллер ничего не
сделает т. к обработки событий на удаление у нас нет.

Удалим все ресурсы, созданные контроллером:
```
kubectl delete mysqls.otus.homework mysql-instance
kubectl delete deployments.apps mysql-instance
kubectl delete pvc mysql-instance-pvc
kubectl delete pv mysql-instance-pv
kubectl delete svc mysql-instance
```

Для удаления ресурсов,   сделаем   deployment,svc,pv,pvc   дочернимиресурсамик   mysql,  дляэтоговтелофункцииmysql_on_create,   послегенерации json манифестовдобавим:

```
# Определяем, что созданные ресурсыявляются дочерними куправляемому CustomResource:    
kopf.append_owner_reference(persistent_volume, owner=body)    
kopf.append_owner_reference(persistent_volume_claim, owner=body)  # addopt    
kopf.append_owner_reference(service, owner=body)    
kopf.append_owner_reference(deployment, owner=body)
# ^ Такимобразомприудалении CR удалятсявсе, связанныесним pv,pvc,svc, deployments
```
Вконецфайладобавимобработкусобытияудаленияресурса mysql:

```
@kopf.on.delete('otus.homework', 'v1', 'mysqls')
def delete_object_make_backup(body, **kwargs):
    return {'message': "mysql and its children resources deleted"}
```

Перезапускаю контроллер, создаю и удаляю mysql-instance, проверяю что все pv, pvc, svc и deployments удалились.








### Деплой оператора

Создаю в папке ./deploy:

-  service-account.yml
-  role.yml
-  role-binding.yml
-  deploy-operator.yml













