# Módulo 2

- Provisione um _cluster_ com pelo menos 3 nós ([KinD](https://kind.sigs.k8s.io/), [Minikube](https://minikube.sigs.k8s.io/), [GCP](https://cloud.google.com/)...);
- Crie uma image qualquer para sua _app_ e poste no [Docker.io](https://hub.docker.com/);
- Crie um _deployment_ com pelo menos 4 replicas da sua _app_.

## Pacotes básicos

### Docker
```
~ # apt-get update
~ # apt-get install ca-certificates curl
~ # install -m 0755 -d /etc/apt/keyrings
~ # curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
~ # chmod a+r /etc/apt/keyrings/docker.asc
~ # echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
~ # apt-get update
~ # apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
~ # docker run hello-world
```

### Kubectl

```
~ # apt-get update
~ # apt-get install -y apt-transport-https gnupg
~ # curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
~ # chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
~ # echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
~ # chmod 644 /etc/apt/sources.list.d/kubernetes.list
~ # apt-get update
~ # apt-get install -y kubectl
~ # kubectl version --client
Client Version: v1.33.2
Kustomize Version: v5.6.0
```

### KinD
```
~ # [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 
~ # chmod +x ./kind
~ # mv ./kind /usr/local/bin/kind
~ # kind --version
kind version 0.29.0
```

> [!TIP]
> Considere instalar o pacote `bash-completion` para facilitar o uso do `docker`, `kubectl` e `kind`.

## Provisionando cluster Kubernets

Arquivo de configuração ` cluster-3-nodes.yml` de criação do cluster:
```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```

```
~ # kind create cluster --config cluster-3-nodes.yml
~ # kind get clusters
cluster-3-nodes
```
```
~ # kubectl get nodes
NAME                            STATUS   ROLES           AGE   VERSION
cluster-3-nodes-control-plane   Ready    control-plane   20m   v1.33.1
cluster-3-nodes-worker          Ready    <none>          20m   v1.33.1
cluster-3-nodes-worker2         Ready    <none>          20m   v1.33.1
cluster-3-nodes-worker3         Ready    <none>          20m   v1.33.1
```
## Criando uma imagem Docker

- Criando `Dockerfile` para uso da imagem do Nginx com uma página customizada:
```
FROM nginx:latest

RUN apt update && apt upgrade -y

COPY files/ /
```
- Criando a imagem e armazenando no Docker.io:
```
docker login
docker build -t nginx-custom
docker tag nginx-custom leandroecomp/nginx-custom
docker push leandroecomp/nginx-custom
```
## Fazendo o deploy da aplicação
Criando o arquivo `nginx-app.yaml`declarando `namespace`, `service` e `deployment` (bem como informações da imagem Docker):
```
apiVersion: v1
kind: Namespace
metadata:
  name: production

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: production
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: leandroecomp/nginx-custom
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: production
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```
- Fazendo o _deploy_ da aplicação:
```
~ # kubectl create -f nginx-app.yaml
namespace/production created
deployment.apps/nginx-deployment created
service/nginx-service created
```
- Ativando encaminhamento de porta temporário:
```
~# kubectl port-forward --address 0.0.0.0,:: -n production services/nginx-service 80:80
Forwarding from 0.0.0.0:80 -> 80
Forwarding from [::]:80 -> 80
```
- Acessando a aplicação

![Screenshot da aplicação teste.](tela.png)
