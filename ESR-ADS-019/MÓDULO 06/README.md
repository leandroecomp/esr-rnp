# Módulo 6

- Criar toda a estrutura de deployment para um registry privado. ( o registry pode ser de livre escolha: registry, harbor, etc)
- Criar um serviço para permitir o acesso interno ao registry
--- 

## Criando um registry privado

```bash
~ # openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key
-subj "/C=BR/ST=PR/L=Foz do Iguaçu/O=Contorq/OU=IT/CN=registry.contorq.com" -x509 -days 365 \
-out certs/domain.crt -extensions EXT \
-config <( printf  "[dn]\nCN=registry.contorq.com\n[req]\ndistinguished_name \
= dn\n[EXT]\nsubjectAltName=DNS:registry.contorq.com\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
Generating a RSA private key
.........................................................++++
......................++++
writing new private key to 'certs/domain.key'
-----
## Criando um deploy para usar umagem do registry privado;
