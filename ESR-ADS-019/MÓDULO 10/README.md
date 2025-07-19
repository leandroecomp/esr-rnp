---

```console
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm completion bash > /etc/bash_completion.d/helm
```
```console
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
`values.yaml`

```yaml
primary:
  persistence:
    enabled: false
```

```console
helm install mysql bitnami/mysql -f values.yaml
NAME: mysql
LAST DEPLOYED: Fri Jul 18 23:06:32 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: mysql
CHART VERSION: 13.0.4
APP VERSION: 9.3.0
...
```

```console
kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          54s
```

```console
MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d)
```

```console
kubectl run mysql-client \
--rm --tty -i --restart='Never' \
--image  docker.io/bitnami/mysql:9.3.0-debian-12-r3 \
--namespace default \
--env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
--command -- bash
If you don't see a command prompt, try pressing enter.
I have no name!@mysql-client:/$
```

```console
I have no name!@mysql-client:/$ mysql -h mysql.default.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 41
Server version: 9.3.0 Source distribution

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
