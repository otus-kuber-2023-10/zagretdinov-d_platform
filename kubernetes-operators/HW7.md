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
```
sudo apt install python3-pip
sudo apt-get update
sudo apt install python3-pip --fix-missing
pip install kopf
pip install kubernetes
pip install jinja2
```

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

___Вопрос:___ почему объект создался, хотя мы создали CR, до того, как запустили контроллер?
___Ответ:___
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
В конец файла добавим обработку события удаления ресурса mysql:

```
@kopf.on.delete('otus.homework', 'v1', 'mysqls')
def delete_object_make_backup(body, **kwargs):
    return {'message': "mysql and its children resources deleted"}
```

Перезапускаю контроллер, создаю и удаляю mysql-instance, проверяю что все pv, pvc, svc и deployments удалились.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/a68bcc27-bff2-48d5-be5e-e75690303204)

Теперь добавим создание   pv,   pvc  для   backup  и   restore   job. Для этого после создания deployment добавим следующий код:

```
# Cоздаем PVC  и PV для бэкапов:
try:        
    backup_pv = render_template('backup-pv.yml.j2', {'name': name})        
    api = kubernetes.client.CoreV1Api()        
    api.create_persistent_volume(backup_pv)
except kubernetes.client.rest.ApiException:
    pass
try:        
    backup_pvc = render_template('backup-pvc.yml.j2', {'name': name})        
    api = kubernetes.client.CoreV1Api()        
    api.create_namespaced_persistent_volume_claim('default', backup_pvc)
except kubernetes.client.rest.ApiException:pass
```

Конструкция   try,   except   -  это обработка исключений,  в данном случае, нужна, чтобы наш контроллер не пытался бесконечно пересоздать pv и pvc для бэкапов, т к их жизненный цикл отличен от жизненного цикла mysql. 
Далее нам необходимо реализовать создание бэкапов и восстановление из них. Для этого будут использоваться Job. По скольку при запуске Job, повторно ее запустить нельзя, намнужно реализовать логику удаления успешно законченных jobs c определенным именем.

Для этого выше всех обработчиков событий     (под функций render_template) добавим следующую функцию:
```
def delete_success_jobs(mysql_instance_name):    
    api = kubernetes.client.BatchV1Api()    
    jobs = api.list_namespaced_job('default')
    for job in jobs.items:        
        jobname = job.metadata.nameif (jobname == f"backup-{mysql_instance_name}-job"):
        if job.status.succeeded == 1:                
            api.delete_namespaced_job(jobname,                          
                                      'default',                                   propagation_policy='Background')

```
Также нам понадобится функция,  для ожидания пока наша   backup   job завершится,  чтобы дождаться пока backup выполнится перед удалением mysql deployment, svc, pv, pvc. 
      Опишем ее:
```
      def wait_until_job_end(jobname):    
         api = kubernetes.client.BatchV1Api()    
         job_finished = False    
         jobs = api.list_namespaced_job('default')
         while (not job_finished) and \            
                  any(job.metadata.name == jobname for job in jobs.items):
             time.sleep(1)        
             jobs = api.list_namespaced_job('default')
             for job in jobs.items:
                 if job.metadata.name == jobname:
                    if job.status.succeeded == 1:                    
                        job_finished = True
```
Добавим запуск backup-job и удаление выполненных jobs в  функцию delete_object_make_backup:
```
name = body['metadata']['name']    
image = body['spec']['image']    
password = body['spec']['password']    
database = body['spec']['database']    

delete_success_jobs(name)
# Cоздаем backup job:    
api = kubernetes.client.BatchV1Api()    
backup_job = render_template('backup-job.yml.j2', {
    'name': name,
    'image': image,
    'password': password,
    'database': database})    
api.create_namespaced_job('default', backup_job)    
wait_until_job_end(f"backup-{name}-job")
```

Добавимгенерацию json изшаблонадля restore-job
```
 restore_job = render_template('restore-job.yml.j2', {
    'name': name,
    'image': image,
    'password': password,
    'database': database})
```
Добавим попытку восстановиться из бэкапов после deployment mysql:

Пытаемся восстановиться из backup
```
try:
    api = kubernetes.client.BatchV1Api()
    api.create_namespaced_job('default', restore_job)
except kubernetes.client.rest.ApiException:
    pass
```

### Деплой оператора
Создаю в папке ./deploy:

-  service-account.yml
-  role.yml
-  role-binding.yml
-  deploy-operator.yml

Отправляю на сервер и применяю.
```
kubectl apply -f ./deploy/service-account.yml
kubectl apply -f ./deploy/role.yml
kubectl apply -f ./deploy/role-binding.yml
kubectl apply -f ./deploy/deploy-operator.yml
```

Добавим зависимость   restore-job   от объектов   mysql   (возле других owner_reference):

```
kopf.append_owner_reference(restore_job, owner=body)
```


Запускаю (издиректории build) и проверяю :

``` 
  kopf run  mysql-operator.py 
  kubectl apply -f deploy/cr.yml
```  
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/fad806fe-41f6-40d2-998d-1cf4e72a9a27)


Проверяю, что все работает, для этого заполняю базу созданного mysql-instance
```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}

kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint \
  unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key \
  (id) );" otus-database

kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( \
  null, 'some data' );" otus-database

kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( \
  null, 'some data-2' );" otus-database
```
Посмастриваю содержимое таблицы:
```
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/73cea870-9568-4f04-ac94-d243ff1a8dd0)

__Собираю докер образ и запушу в докерхаб__
```
docker build -t zagretdinov/otus:kubernetes-operators-mysql kubernetes-operators/build/. && \
docker push zagretdinov/otus:kubernetes-operators-mysql
```

Удаляю mysql-instance:
```
kubectl delete mysqls.otus.homework mysql-instance
```
Теперь ```kubectl get pv``` показывает, что PV для mysql больше нет, а
```kubectl get jobs.batch``` показывает:


Заново задеплою оператор, уже на основе образа, который был запушен в докерхаб. образ путь добавил в deploy-operator.yml.
```
kubectl apply -f kubernetes-operators/deploy/crd.yml -f kubernetes-operators/deploy/service-account.yml -f  kubernetes-operators/deploy/role.yml -f  kubernetes-operators/deploy/role-binding.yml
kubectl apply -f kubernetes-operators/deploy/deploy-operator.yml
kubectl apply -f kubernetes-operators/deploy/cr.ym
```
- прверяю

```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint
unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key
(id) );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (
null, 'some data' );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (
null, 'some data-2' );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
```

### Проверим, что все работает работает

Удаляю mysql-instance:
```
kubectl delete mysqls.otus.homework mysql-instance
kubectl delete pv mysql-instance-pv
```
Проверяю что все удалилось.

```
kubectl get pv
kubectl get jobs.batch
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ad67be02-f270-4f19-8113-3e15d39b1b15)

### Создаю заного
```
kubectl apply -f kubernetes-operators/deploy/cr.yml
kubectl get jobs.batch 
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/9b77993a-271c-45d3-9bf4-b17d491d64bb)

Немного ожидаю буквально секунды проверяю.
```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/d79ec000-6149-4c00-80f3-08aa92961f9d)


## Задание со * (1)
• Исправить контроллер, чтобы он писал в status subresource
• Описать изменения в README.md (показать код, объяснить, что он делает)
• В README показать, что в status происходит запись
• Например, при успешном создании mysql-instance, kubectl describe

mysqls.otus.homework mysql-instance может показывать:
```
Status:
  Kopf:
  mysql_on_create:
    Message: mysql-instance created without restore-job
```

В mysql-operator.py добавил в код функции переменную msg в зависимости от успешности restore-job и вывод этой переменной, которая попадает в Status.
```
# Пытаемся восстановиться из backup
    try:
        api = kubernetes.client.BatchV1Api()
        api.create_namespaced_job('default', restore_job)
        msg = "mysql-instance created with restore-job" 
    except kubernetes.client.rest.ApiException:
        msg = "mysql-instance created without restore-job" 
        pass

    return {'Message': msg, 'mysql-instance': name}
```
при запуске можно увидеть следующее значение.

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/7d7af277-7050-4e39-83a8-998fb9641821)
