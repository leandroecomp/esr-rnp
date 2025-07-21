

---
<p align="center">
<img  width="50%" src="moodle.svg">
</p>



`values.yaml`
```yaml
mariadb:
  image: mariadb:10.11
  service:
    type: ClusterIP
    port: '3306'
    targetPort: '3306'
  env:
    MARIADB_ROOT_PASSWORD: rootpass
    MARIADB_DATABASE: moodle
    MARIADB_USER: moodleuser
    MARIADB_PASSWORD: moodlepass
  ports:
    containerPort: '3306'

moodle:
  image: bitnami/moodle:5.0
  service:
    type: NodePort
    port: '8080'
    nodePort: '30080'
  env:
    MOODLE_DATABASE_TYPE: mariadb
    MOODLE_DATABASE_HOST: moodle-db-svc
    MOODLE_DATABASE_PORT_NUMBER: '3306'
    MOODLE_DATABASE_NAME: moodle
    MOODLE_DATABASE_USER: moodleuser
    MOODLE_DATABASE_PASSWORD: moodlepass
  ports: 
    containerPort: '8080'
```
`moodle-db-deploy.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: moodle-db-svc
spec:
  selector:
    app: moodle-db
  type: {{ .Values.mariadb.service.type }}
  ports:
    - port: {{ .Values.mariadb.service.port }}
      targetPort: {{ .Values.mariadb.service.targetPort }}
  clusterIP: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: moodle-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: moodle-db
  template:
    metadata:
      labels:
        app: moodle-db
    spec:
      containers:
        - name: mariadb
          image: {{ .Values.mariadb.image }}
          env:
            - name: MARIADB_ROOT_PASSWORD
              value: {{ .Values.mariadb.env.MARIADB_ROOT_PASSWORD }}              
            - name: MARIADB_DATABASE
              value: {{ .Values.mariadb.env.MARIADB_DATABASE }}
            - name: MARIADB_USER
              value: {{ .Values.mariadb.env.MARIADB_USER }}
            - name: MARIADB_PASSWORD
              value: {{ .Values.mariadb.env.MARIADB_PASSWORD }}
          ports:
            - containerPort: {{ .Values.mariadb.ports.containerPort }}
```
`moodle-app-deploy.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: moodle-app-svc
spec:
  selector:
    app: moodle-app
  type: {{ .Values.moodle.service.type }}
  ports:
    - port: {{ .Values.moodle.service.port }}
      targetPort: {{ .Values.moodle.ports.containerPort }}
      nodePort: {{ .Values.moodle.service.nodePort }}  # Porta exposta no Node
   
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: moodle-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: moodle-app
  template:
    metadata:
      labels:
        app: moodle-app
    spec:
      containers:
        - name: moodle
          image: {{ .Values.moodle.image }}
          env:
            - name: MOODLE_DATABASE_TYPE
              value: {{ .Values.moodle.env.MOODLE_DATABASE_TYPE }}            
            - name: MOODLE_DATABASE_HOST
              value: {{ .Values.moodle.env.MOODLE_DATABASE_HOST }}            
            - name: MOODLE_DATABASE_PORT_NUMBER
              value: '3306'
            - name: MOODLE_DATABASE_NAME
              value: {{ .Values.moodle.env.MOODLE_DATABASE_NAME }}                        
            - name: MOODLE_DATABASE_USER
              value: {{ .Values.moodle.env.MOODLE_DATABASE_USER }}              
            - name: MOODLE_DATABASE_PASSWORD
              value: {{ .Values.moodle.env.MOODLE_DATABASE_PASSWORD }}              
          ports:
            - containerPort: {{ .Values.moodle.ports.containerPort }}
```
```console
helm install moodle helm
```

<p align="center">
<img  width="50%" src="moodle_tela.png">
</p>
