# Módulo 4

Cenário

Considerando o uso do kind, crie um cluster com 3 nodes workrs representando o nodepool A e 2 nodes workers representando o nodepool B

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


