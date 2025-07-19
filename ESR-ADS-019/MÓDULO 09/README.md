Para que seja considerada entregue você deve anexar a esta atividade no AVA uma imagem (nos formatos .png ou .jpg) do seu navegador acessando o dashboard Kubernetes cluster monitoring (ID `3119` ou `6417`) via interface web do Grafana.
---
`cadvisor.yaml`
```yaml
kind: Namespace
metadata:
  labels:
    app: cadvisor
  name: cadvisor
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: cadvisor
  name: cadvisor
  namespace: cadvisor
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: docker/default
  labels:
    app: cadvisor
  name: cadvisor
  namespace: cadvisor
spec:
  selector:
    matchLabels:
      app: cadvisor
      name: cadvisor
  template:
    metadata:
      labels:
        app: cadvisor
        name: cadvisor
    spec:
      tolerations:
      # this toleration is to have the daemonset runnable on master nodes
      # remove it if your masters can't run pods
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      automountServiceAccountToken: false
      containers:
      - image: gcr.io/cadvisor/cadvisor:v0.44.0
        name: cadvisor
        args:
        - --storage_duration=5m0s
        - --housekeeping_interval=10s
        # you may need to provide your cluster container runtime socket path, e.g.:
        # - -containerd=/run/k3s/containerd/containerd.sock
        # - -docker=unix:///var/run/docker.sock
        securityContext:
          privileged: true
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        volumeMounts:
        - mountPath: /rootfs
          name: rootfs
          readOnly: true
        - mountPath: /var/log
          name: var-log
          readOnly: true
        - mountPath: /var/run
          name: var-run
          readOnly: true
        - mountPath: /sys
          name: sys
          readOnly: true
        - mountPath: /var/lib/containers
          name: containers
          readOnly: true
        - mountPath: /var/lib/docker
          name: docker
          readOnly: true
        - mountPath: /dev/disk
          name: disk
          readOnly: true
      serviceAccountName: cadvisor
      terminationGracePeriodSeconds: 30
      volumes:
      - hostPath:
          path: /
        name: rootfs
      - hostPath:
          path: /var/log
        name: var-log
      - hostPath:
          path: /var/run
        name: var-run
      - hostPath:
          path: /sys
        name: sys
      - hostPath:
          path: /var/lib/containers
        name: containers
      - hostPath:
          path: /var/lib/docker
        name: docker
      - hostPath:
          path: /dev/disk
        name: disk
```

`loki-grafana-nodeport.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: grafana
  labels:
    app: loki-grafana-nodeport
  name: loki-grafana-nodeport
spec:
  ports:
  - name: "80"
    nodePort: 30080
    port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app.kubernetes.io/instance: loki
    app.kubernetes.io/name: grafana
  type: NodePort
```

![Screenshot da aplicação teste.](grafana1.png)
![Screenshot da aplicação teste.](grafana2.png)
