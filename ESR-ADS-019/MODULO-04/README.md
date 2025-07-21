# Módulo 4
Cenário: Considerando o uso do kind, crie um cluster com 3 nodes workrs representando o nodepool A e 2 nodes workers representando o nodepool B
A ideia é que os nodes pools tenham esta característica: (no caso do kind isso ficará apenas convencionado os nodepools serão iguais)

nodepool - tipo A
 - hardware=low
 - Apps básicas = ngnix

nodepool - tipo B
 - hardware=high
 - Apps Criticas = apache

Tarefa:
- Fazer o deploy do nginx sem ter configurado taints e tolerations
- Configurar taint e tolerations
- Fazer o deploy de apache
---
`nginx-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 5
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

`apache-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
spec:
  selector:
    matchLabels:
      app: apache
  replicas: 3
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache
        image: httpd:latest
        ports:
        - containerPort: 80
```

Observando a execução dos pods, percebemos que estão espalhados aleatoriamente pel pelos nodes:

```console
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                                 NODE              STATUS
apache-deployment-5fd955856f-mw5rd   cluster-worker2   Running
apache-deployment-5fd955856f-stft9   cluster-worker    Running
apache-deployment-5fd955856f-tqrqx   cluster-worker3   Running
nginx-deployment-96b9d695-7p5qp      cluster-worker4   Running
nginx-deployment-96b9d695-9fmgr      cluster-worker    Running
nginx-deployment-96b9d695-9rtlc      cluster-worker2   Running
nginx-deployment-96b9d695-cj7g5      cluster-worker3   Running
nginx-deployment-96b9d695-htxs5      cluster-worker5   Running
```

Adicionando `taints` de exigência de hardware aos nodes: 3 com `hardware=low` e 2 com `hardware=high`.
Isso permitira que apenas pods com a correpondente tolerância sejam executados nestes nodes.
```console
kubectl taint nodes cluster-worker cluster-worker2  cluster-worker3 hardware=low:NoExecute
node/cluster-worker tainted
node/cluster-worker2 tainted
node/cluster-worker3 tainted
kubectl taint nodes cluster-worker4 cluster-worker5 hardware=high:NoExecute
node/cluster-worker4 tainted
node/cluster-worker5 tainted
```
Verificando os nodes vemos que estão agora todos pendentes já que nenhum deployment possui `tolerance` configurado.

```console
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                                 NODE     STATUS
apache-deployment-5fd955856f-7bmpf   <none>   Pending
apache-deployment-5fd955856f-fq9mq   <none>   Pending
apache-deployment-5fd955856f-sbtsz   <none>   Pending
nginx-deployment-96b9d695-8lsjm      <none>   Pending
nginx-deployment-96b9d695-9z2vn      <none>   Pending
nginx-deployment-96b9d695-fv7p7      <none>   Pending
nginx-deployment-96b9d695-gggqt      <none>   Pending
nginx-deployment-96b9d695-pwv9j      <none>   Pending
```
Adicionando `tolerations` às configurações de deployment. Use kubectl edit para isso.

`nginx-deployment.yaml`
```yaml
...
spec:
...
  template:
...
    spec:
...
      tolerations:
      - key: "hardware"
        operator: "Equal"
        value: "low"
        effect: "NoExecute"
...
```
`apache-deployment.yaml`
```yaml
...
spec:
...
  template:
...
    spec:
...
      tolerations:
      - key: "hardware"
        operator: "Equal"
        value: "high"
        effect: "NoExecute"
...
```
Aplicando as novas configurações dos `deploymnents`
```console
kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
kubectl apply -f apache-deployment.yaml
deployment.apps/apache-deployment configured
```

Verificamos agora que os pods do apache estão alocados em nodes que tains de alta capacide e o nginx nos demais nodes.

```console
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
NAME                                 NODE              STATUS
apache-deployment-67d4dfb644-4gjpp   cluster-worker5   Running
apache-deployment-67d4dfb644-gwnqj   cluster-worker4   Running
apache-deployment-67d4dfb644-t2c4v   cluster-worker4   Running
nginx-deployment-77d5bbc658-ccqqt    cluster-worker2   Running
nginx-deployment-77d5bbc658-dk9kh    cluster-worker3   Running
nginx-deployment-77d5bbc658-fj4tk    cluster-worker3   Running
nginx-deployment-77d5bbc658-mg4f4    cluster-worker2   Running
nginx-deployment-77d5bbc658-rdpwc    cluster-worker    Running
```

