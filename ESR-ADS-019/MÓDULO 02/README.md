# Módulo 2

- Provisione um _cluster_ com pelo menos 3 nós ([KinD](https://kind.sigs.k8s.io/), [Minikube](https://minikube.sigs.k8s.io/), [GCP](https://cloud.google.com/)...);
- Crie uma image qualquer para sua _app_ e poste no [Docker.io](https://hub.docker.com/);
- Crie um _deployment_ com pelo menos 4 replicas da sua _app_.

## Instalando cluster Kubernets

```
~ # [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 
~ # chmod +x ./kind
~ # mv ./kind /usr/local/bin/kind
~ # kind --version
kind version 0.29.0
```

## Criando uma imagem Docker
## Fazendo o deploy da aplicação

