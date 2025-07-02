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

```bash
~ # kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
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
```bash
~ # kubectl taint nodes cluster-worker cluster-worker2  cluster-worker3 hardware=low:NoExecute
node/cluster-worker tainted
node/cluster-worker2 tainted
node/cluster-worker3 tainted
~ # kubectl taint nodes cluster-worker4 cluster-worker5 hardware=high:NoExecute
node/cluster-worker4 tainted
node/cluster-worker5 tainted
```
