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
__Домашннее задание еще даже не началось а тут уже появились кастыли__

```
error: unable to recognize "deploy/cr.yml": no matches for kind "MySQL" in version "otus.homework/v1"
```
Ошибка связана с отсутсвием объектов типа MySQL в API kubernetes.
Исправить это недоразумение имеющимися манифестами не удалось были прменены другие манифесты...

deploy/cr.yml
```
---
apiVersion: otus.homework/v1
kind: MySQL
metadata:
  name: mysql-instance
spec:
  image: mysql:5.7
  database: otus-database
  password: otuspassword
  storage_size: 1Gi
# useless_data: "useless info
```
deploy/crd.yml
```
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: mysqls.otus.homework
spec:
  group: otus.homework
  preserveUnknownFields: false
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            # x-kubernetes-preserve-unknown-fields: false
            apiVersion:
              type: string
            kind:
              type: string
            metadata:
              type: object
              properties:
                name:
                  type: string
            spec:
              type: object
              properties:
                image:
                  type: string
                database:
                  type: string
                password:
                  type: string
                storage_size:
                  type: string
              required: ["image", "database", "password", "storage_size"]
          required: ["apiVersion", "kind", "metadata", "spec"]
  scope: Namespaced
  names:
    kind: MySQL
    plural: mysqls
    singular: mysql
    shortNames:
      - ms
```

то есть у меня ругался на эту ошибку...
```
Error from server (BadRequest): error when creating "deploy/cr.yml": MySQL in version "v1" cannot be handled as a MySQL: strict decoding error: unknown field "spec"
```
выше добавленные манифесты исправили это не дорозумение...

### Взаимодействие с объектами CR CRD..

Согласно командам все отработало.
```
kubectl get crd
kubectl get mysqls.otus.homework
kubectl describe mysqls.otus.homework mysql-instance
```
![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/92994b3e-7fb5-4fae-88e9-e79523868569)
















