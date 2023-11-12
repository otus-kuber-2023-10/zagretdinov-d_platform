### Тема: Kubernetes controllers. ReplicaSet, Deployment, DaemonSet.

__Подготовка:__
_Изначально должно быть установленно:_

- Kubelet, Kubectl, docker.

```
sudo mkdir -p /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install -y kubelet kubectl docker-ce docker-ce-cli containerd.io
```
- установим kind
```
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64" 
chmod +x ./kind 
sudo mv ./kind /usr/local/bin/
```
Отправляю файл kind-config.yaml для локального кластера на сервер и запускаю.

В результате:




