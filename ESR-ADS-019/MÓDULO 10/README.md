
---
```YAML
apiVersion: v1
kind: Service
metadata:
  name: moodle-app-svc
spec:
  selector:
    app: moodle-app
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080  # Porta exposta no Node
```
