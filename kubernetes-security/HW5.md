## Тема: Security

___Задание:___ 

- настройка сервисных аккаунтов и ограничение прав для них

___Цель:___ 

- научиться создавать service account.
- настрить их права в рамках одного namespace и кластера целиком.

___Выполнение:___

####task01
- Создать Service Account bob, дать ему роль admin в рамках всего кластера
- Создать Service Account dave без доступа к кластеру

Созданные три манифеста отправляю на сервер и применяю.

```
kubectl apply -f .
kubectl get sa
kubectl describe sa bob
kubectl describe sa dave
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/887dd128-ae41-49ac-94e5-66e79bd99203)

Теперь с помощью команд проверяю доступность аккаунтов.
```
kubectl get rolebindings,clusterrolebindings --all-namespaces -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name' | grep dave
kubectl get rolebindings,clusterrolebindings --all-namespaces -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name' | grep bob
kubectl auth can-i get deployments --as system:serviceaccount:default:bob
kubectl auth can-i get deployments --as system:serviceaccount:default:bob --all-namespaces=true
kubectl auth can-i get pods --as system:serviceaccount:default:dave
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/270611e8-85ad-46bc-9f5b-2feb5d831923)

Как видно по результатам dave не получил доступ к кластеру, а bob имеет доступ в кластер и роль админа. 

####task02
- Создать Namespace prometheus.
- Создать Service Account carol в этом Namespace.
- Дать всем Service Account в Namespace prometheus возможность делать get , list , watch в отношении Pods всего кластера.


