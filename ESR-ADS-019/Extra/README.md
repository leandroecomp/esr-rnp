

---
<p align="center">
<img  width="50%" src="moodle.svg">
</p>


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
