# Módulo 6

- Criar toda a estrutura de deployment para um registry privado. ( o registry pode ser de livre escolha: registry, harbor, etc)
- Criar um serviço para permitir o acesso interno ao registry
--- 

## Criando um registry privado

```console
mkdir -p ~/registry/{images,certs,auth}
cd ~/registry
```

```console
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -subj "/C=BR/ST=PR/L=Foz do
Iguaçu/O=Contorq/OU=IT/CN=registry.contorq.com" -x509 -days 365 -out certs/domain.crt -extensions EXT
config <( printf  "[dn]\nCN=registry.contorq.com\n[req]\ndistinguished_name
= dn\n[EXT]\nsubjectAltName=DNS:registry.contorq.com\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
Generating a RSA private key
.........................................................++++
......................++++
writing new private key to 'certs/domain.key'
-----
```
## Criando um deploy para usar umagem do registry privado;

```console
 mkdir -p /etc/docker/certs.d/registry.contorq.com:30500
```
```console
cp certs/domain.crt /etc/docker/certs.d/registry.contorq.com:30500/ca.crt
```
```console
docker pull leandroecomp/nginx-custom
Using default tag: latest
latest: Pulling from leandroecomp/nginx-custom
(...)
Status: Downloaded newer image for leandroecomp/nginx-custom:latest
docker.io/leandroecomp/nginx-custom:latest
```

```console
docker tag leandroecomp/nginx-custom:latest registry.contorq.com:30500/nginx-custom
```

```console
docker login registry.contorq.com:30500
Username: master
Password: blaster
(...)
Login Succeeded
```
```console
docker pull registry.contorq.com:30500/nginx-custom:latest
latest: Pulling from leandroecomp/nginx-custom
dad67da3f26b: Pull complete
3b00567da964: Pull complete
56b81cfa547d: Pull complete
1bc5dc8b475d: Pull complete
979e6233a40a: Pull complete
d2a7ba8dbfee: Pull complete
32e44235e1d5: Pull complete
040898630440: Pull complete
172a5a6467fc: Pull complete
acf963027756: Pull complete
Digest: sha256:1684f19262f73197eac6a9004c43a49107a42b8a85a06f96758ed91d65dbf479
Status: Downloaded newer image for registry.contorq.com:30500/nginx-custom:latest
registry.contorq.com:30500/nginx-custom:latest
```

```console
kubectl create secret docker-registry registry-secret \
--docker-server=https://registry.contorq.com:30500 \
--docker-username=master \
--docker-password=blaster
```

```console
kubectl create deploy private-app --image=registry.contorq.com:30500/nginx-custom --replicas=2
```
```console
kubectl edit deploy private-app
```
```yaml
imagePullSecrets:
- name: registry-secret
```
```console
kubectl get deploy private-app
NAME         READY UP-TO-DATE AVAILABLE AGE
private-app  2/2   2          2         34m
```
