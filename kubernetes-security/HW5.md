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

В результате создал 4 манифеста и применил их.
Последующем использовал команды.
```
kubectl apply -f .
kubectl get ns
kubectl get sa -n prometheus
kubectl get ClusterRole | grep prometheus-reading
kubectl describe ClusterRole  prometheus-reading
kubectl get ClusterRoleBinding  |grep  bind-allclusterpod
kubectl describe ClusterRoleBinding bind-allclusterpods
```
![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/ad01fe44-8d66-4ff2-b2f7-32933c814213)

```
kubectl auth can-i get deployments --as system:serviceaccount:prometheus:carol
kubectl auth can-i list pods --as system:serviceaccount:prometheus:carol -n prometheus
kubectl auth can-i list pods --as system:serviceaccount:prometheus:carol
kubectl auth can-i list pods --as system:serviceaccount:prometheus:cindy -n prometheus
kubectl auth can-i list pods --as system:serviceaccount:prometheus:cindy
kubectl auth can-i list pods --as system:serviceaccount:default:dan -n prometheus
kubectl auth can-i list pods --as system:serviceaccount:default:dan
```

![изображение](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/e29ea6cd-f42f-47b4-aca9-beece69357fb)

#### task03

   - Создать Namespace 'dev'
   - Создать Service Account 'jane' в Namespace 'dev'
   - Дать 'jane' роль 'admin' в рамках Namespace 'dev'
   - Создать Service Account 'ken' в Namespace 'dev'
   - Дать 'ken' роль 'view' в рамках Namespace 'dev'

Создаю согласно заданию манифесты и отправляю на сервер.

```
kubectl apply -f .
kubectl get ns
kubectl get sa -n dev
kubectl get RoleBinding -n dev
kubectl describe RoleBinding -n dev bind-jane
kubectl describe RoleBinding -n dev bind-ken
```

![image](https://github.com/otus-kuber-2023-10/zagretdinov-d_platform/assets/85208391/2dadd8ff-dae9-4591-9f59-521fc564b571)
