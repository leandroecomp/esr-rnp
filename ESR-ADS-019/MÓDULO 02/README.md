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
~ # apt-get install -y apt-transport-https ca-certificates curl gnupg
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

## Provisionando cluster Kubernets
## Criando uma imagem Docker
## Fazendo o deploy da aplicação

