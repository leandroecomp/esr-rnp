# Módulo 3

- Fazer deploy de uma app dentro do cluster (yaml);
- Identificar em que node está sendo executado;
- Deixar o node acima indisponivel;
- Observar o comportamento da ap, para qual node ela foi alocada;
- Restabelecer o node.
---

Para esta tarefa foi utilizado o mesmo procedimento do [MÓDULO 02](https://github.com/leandroecomp/esr-rnp/edit/main/ESR-ADS-019/M%C3%93DULO%2002), com um cluster de 3 nodes e uma aplicação web no Nginx.

```console
kubectl get pods --namespace production -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                               NODE                     STATUS
nginx-deployment-c9884845d-pq4wv   cluster-3-nodes-worker   Running
```
Como podemos ver o pod da aplicação está sendo excecutada no node `cluster-3-nodes-worker`.

Primeiramente marcar um node como **não-agendável**, o que impede que novos pods sejam agendados nesse node.
```console
kubectl cordon cluster-3-nodes-worker
```
Desabilitando o node, onde  `--ignore-daemonsets` ignora pods gerenciados por DaemonSets.
```console
kubectl drain --ignore-daemonsets cluster-3-nodes-worker
```
Uma vez desabilitado é possível verificar que o pode migrou para outro node.
```console
kubectl get pods --namespace production -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                               NODE                      STATUS
nginx-deployment-c9884845d-lzgvz   cluster-3-nodes-worker2   Running
```

Habilitando novamente o node anterior vemos que mesmo assim a o pod não retornou.
```console
kubectl uncordon cluster-3-nodes-worker
kubectl get pods --namespace production -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                               NODE                      STATUS
nginx-deployment-c9884845d-lzgvz   cluster-3-nodes-worker2   Running
```

