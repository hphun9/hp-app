# 📦 Base App Helm Chart

A flexible and production-ready Helm chart for Kubernetes micro-services.  
Supports Deployment, Service, Ingress, CronJobs, Jobs, ConfigMaps, Secrets, and HPA.  
Designed to be reused as a base chart for any application by overriding values.

---

## 🧱 Features

- Deployment (API / Worker)
- Service (ClusterIP / NodePort / LoadBalancer)
- Ingress (NGINX / Traefik / Microk8s)
- Multiple CronJobs
- Multiple Jobs
- ConfigMaps & Secrets
- Custom env & envFrom
- Custom volumes & mounts
- Optional HPA
- Fully compatible with **microk8s**
- Publishable to OCI registries (Harbor, Nexus, ECR…)

---

## 📁 Directory Structure

```bash
base-app/
  Chart.yaml
  values.yaml
  templates/
    _helpers.tpl
    deployment.yaml
    service.yaml
    ingress.yaml
    configmap.yaml
    secret.yaml
    cronjobs.yaml
    jobs.yaml
    serviceaccount.yaml
    hpa.yaml
    NOTES.txt
  README.md
```

---

# 🚀 Install Locally (Microk8s)

### 1. Enable required addons

```bash
microk8s enable dns ingress
```

(Optional: also enable metrics-server if you want HPA.)

```bash
microk8s enable metrics-server
```

### 2. Install the chart from local directory

```bash
helm install my-app ./base-app -f my-values.yaml
```

### 3. Upgrade release

```bash
helm upgrade my-app ./base-app -f my-values.yaml
```

### 4. Uninstall release

```bash
helm uninstall my-app
```

---

# 📦 Package & Push to Harbor (OCI)

## 1. Package the chart

From the directory that contains `base-app/`:

```bash
helm package base-app
# -> base-app-0.1.0.tgz
```

## 2. Login to Harbor (OCI registry)

```bash
helm registry login harbor.example.com   --username admin   --password <password>
```

## 3. Push the chart to Harbor

```bash
helm push base-app-0.1.0.tgz oci://harbor.example.com/helm
```

You should now see the chart in your Harbor project (e.g. `helm`).

---

# 📥 Install the Chart from Harbor

### 1. Install

```bash
helm install my-app oci://harbor.example.com/helm/base-app   --version 0.1.0   -f my-values.yaml
```

### 2. Upgrade

```bash
helm upgrade my-app oci://harbor.example.com/helm/base-app   --version 0.1.0   -f my-values.yaml
```

### 3. List releases

```bash
helm list
```

---

# 🧩 Using This Chart for a New Application

Create a values file, for example `my-values.yaml`:

```yaml
global:
  image:
    repository: my-registry.local/my-app
    tag: "1.0.0"
  env:
    - name: ENV
      value: "prod"

deployment:
  enabled: true
  replicaCount: 2
  ports:
    - name: http
      containerPort: 8080
      protocol: TCP

service:
  enabled: true
  type: ClusterIP
  port: 80
  targetPort: http

cronjobs:
  enabled: true
  jobs:
    - name: daily-cleanup
      schedule: "0 0 * * *"
      command: ["sh", "-c"]
      args: ["python cleanup.py"]
      env:
        - name: JOB_NAME
          value: daily-cleanup
```

Then install using Harbor:

```bash
helm install my-app oci://harbor.example.com/helm/base-app   --version 0.1.0   -f my-values.yaml
```

Or from local directory:

```bash
helm install my-app ./base-app -f my-values.yaml
```

---

# 🛠 Deployment (API / Worker)

Enable the Deployment:

```yaml
deployment:
  enabled: true
  replicaCount: 2
```

Configure image (can be global or deployment-specific):

```yaml
global:
  image:
    repository: my-registry.local/my-api
    tag: "2.0.0"
    pullPolicy: IfNotPresent
```

Define ports:

```yaml
deployment:
  ports:
    - name: http
      containerPort: 8080
      protocol: TCP
```

Optional: command & args:

```yaml
deployment:
  command: ["sh", "-c"]
  args: ["./start.sh"]
```

---

# 🌐 Service

Enable Service:

```yaml
service:
  enabled: true
  type: ClusterIP
  port: 80
  targetPort: http
```

Examples:

- `ClusterIP` (inside-cluster access)
- `NodePort` (expose on node ports – for local dev)
- `LoadBalancer` (cloud providers)

```yaml
service:
  type: NodePort
  port: 80
```

Check the service:

```bash
kubectl get svc
```

---

# 🌍 Ingress

Example configuration (for NGINX Ingress on microk8s):

```yaml
ingress:
  enabled: true
  className: nginx
  annotations: {}
  hosts:
    - host: my-app.local
      paths:
        - path: /
          pathType: Prefix
  tls: []
```

Update `/etc/hosts` on your machine:

```bash
sudo sh -c 'echo "127.0.0.1 my-app.local" >> /etc/hosts'
```

Access in browser:

```text
http://my-app.local
```

---

# ⏱ CronJobs

Enable multiple CronJobs:

```yaml
cronjobs:
  enabled: true
  jobs:
    - name: sample
      schedule: "*/5 * * * *"
      command: ["sh", "-c"]
      args: ["echo hello from cron && date"]
      env:
        - name: FOO
          value: "bar"
      resources:
        limits:
          cpu: "100m"
          memory: "128Mi"
        requests:
          cpu: "50m"
          memory: "64Mi"
```

Check CronJobs:

```bash
kubectl get cronjobs
kubectl get jobs
kubectl logs job/<job-name>
```

---

# 🧨 One-off Jobs

Define Jobs:

```yaml
jobs:
  enabled: true
  items:
    - name: migrate-db
      ttlSecondsAfterFinished: 3600
      backoffLimit: 3
      command: ["sh", "-c"]
      args: ["python migrate.py"]
      env:
        - name: DB_MIGRATION
          value: "true"
```

After deploying the chart, check Jobs:

```bash
kubectl get jobs
kubectl logs job/<release>-base-app-migrate-db
```

If you want to rerun a similar Job manually:

```bash
kubectl create job run-migrate-db   --from=job/<existing-job-name>
```

---

# 📑 ConfigMaps

Define application configuration:

```yaml
configMaps:
  enabled: true
  items:
    - name: my-app-config
      data:
        APP_NAME: "demo-app"
        LOG_LEVEL: "info"
```

Use these ConfigMaps via `envFrom` in Deployment/CronJobs/Jobs:

```yaml
global:
  envFrom:
    configMaps:
      - my-app-config
```

---

# 🔐 Secrets

Define generic Secrets:

```yaml
secrets:
  enabled: true
  items:
    - name: my-app-secret
      stringData:
        DB_USER: "admin"
        DB_PASSWORD: "super-secret"
        API_KEY: "xxx"
```

Use via `envFrom`:

```yaml
global:
  envFrom:
    secrets:
      - my-app-secret
```

Kubernetes will mount them as environment variables.

---

# 🌡 Environment Variables

Global env for all containers:

```yaml
global:
  env:
    - name: ENV
      value: "prod"
    - name: TZ
      value: "Asia/Ho_Chi_Minh"
```

Deployment-specific env:

```yaml
deployment:
  env:
    - name: WORKER_CONCURRENCY
      value: "4"
```

CronJob-specific env:

```yaml
cronjobs:
  jobs:
    - name: cleanup
      env:
        - name: TARGET
          value: "/tmp"
```

Job-specific env:

```yaml
jobs:
  items:
    - name: migrate-db
      env:
        - name: AUTO_MIGRATE
          value: "true"
```

---

# 📈 Autoscaling (HPA)

To enable Horizontal Pod Autoscaler:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80
```

Requires metrics server (microk8s: `microk8s enable metrics-server`).

Check HPA:

```bash
kubectl get hpa
```

---

# 🧱 Volumes & Volume Mounts

For the main Deployment:

```yaml
deployment:
  extraVolumes:
    - name: data
      emptyDir: {}
  extraVolumeMounts:
    - name: data
      mountPath: /var/data
```

For CronJobs / Jobs:

```yaml
cronjobs:
  jobs:
    - name: sample
      extraVolumes:
        - name: tmp
          emptyDir: {}
      extraVolumeMounts:
        - name: tmp
          mountPath: /tmp

jobs:
  items:
    - name: migrate-db
      extraVolumes:
        - name: config
          configMap:
            name: my-app-config
      extraVolumeMounts:
        - name: config
          mountPath: /etc/app
```

---

# 🔒 Service Account

By default, the chart creates a ServiceAccount.

```yaml
serviceAccount:
  create: true
  name: ""          # default: release-based name
  annotations: {}
```

If you want to use an existing ServiceAccount:

```yaml
serviceAccount:
  create: false
  name: my-existing-sa
```

---

# 🔍 Debugging & Observability

Get all resources for this release:

```bash
kubectl get all -l app.kubernetes.io/instance=my-app
```

Check pods:

```bash
kubectl get pods
kubectl logs -f <pod-name>
kubectl describe pod <pod-name>
```

---

# 🧹 Cleanup

Uninstall the Helm release:

```bash
helm uninstall my-app
```

Optionally, delete all Jobs and CronJobs in the namespace (careful in shared environments):

```bash
kubectl delete jobs --all
kubectl delete cronjobs --all
```

---

This chart is meant to be a generic, reusable base for all your microservices.  
You only need to maintain **one** chart and plug in specific `values.yaml` for each application or environment.
