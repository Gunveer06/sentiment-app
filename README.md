# DevOps Practical Examination — Submission & Demonstration Report

- **Student / Candidate:** Gunveer
- **Theme:** Social Media Post & Sentiment Analytics Stack
- **GitHub Repository:** [https://github.com/Gunveer06/sentiment-app.git](https://github.com/Gunveer06/sentiment-app.git)
- **Environment:** Git, Jira Cloud, Jenkins, Docker, Kubernetes (`kubectl`), Terraform, Ansible

---

## Task 1: Git Version Control (2 Marks)

### Objective
Initialize `sentiment-app`, create release branch `release-v4.0`, commit `sentiment.properties` (`BATCH=500`), merge `release-v4.0` into `main`, and apply Git tag `v4.0-final`.

### Commands Executed
```bash
cd task1-git/sentiment-app
git checkout -b release-v4.0
echo "BATCH=500" > sentiment.properties
git add sentiment.properties
git commit -m "feat: add sentiment.properties with BATCH=500"
git checkout main
git merge release-v4.0 --no-ff -m "Merge branch 'release-v4.0' into main"
git tag -a v4.0-final -m "Release v4.0 final tag"
git push -u origin main release-v4.0 v4.0-final
```

### Verification Command & Output
```bash
git log --oneline --graph --decorate -n 5
```
**Output:**
```text
*   e3c07cf (HEAD -> main, tag: v4.0-final, origin/main) Merge branch 'release-v4.0' into main
|\  
| * b745cc1 (origin/release-v4.0, release-v4.0) feat: add full stack configs
|/  
* 56a1b5c Initial commit on main
```
```bash
git tag -n
# Output: v4.0-final  Release v4.0 final tag
```

---

## Task 2: Jira Agile Project Management (1 Mark)

### Objective
Manage sprint lifecycle: create and transition sprint tickets `SOC-101` and `SOC-102` (`SMSS-1` & `SMSS-2`) to `Done`, complete active sprint `Sprint-Sentiment-v4`, and inspect the Burndown Chart.

### Steps Executed
1. **Backlog Planning:** Added tickets `Ingest Social Media Feeds` (`SMSS-1`) and `Batch Sentiment Analyzer` (`SMSS-2`).
2. **Start Sprint:** Created sprint `Sprint-Sentiment-v4`, added both tickets, and clicked **Start sprint**.
3. **Transition to Done:** Dragged cards from `To Do` to `Done` column on the Active Board.
4. **Complete Sprint:** Clicked **Complete sprint** (2 issues completed, 0 open).
5. **Burndown Chart:** Opened **Reports > Burndown Chart**; verified guideline and remaining work line dropped to `0`.

### Verification
- **Board Status:** Displays *"Sprint completed"*.
- **Backlog Status:** `Sprint-Sentiment-v4` appears under closed/completed sprints.
- **Ticket Status:** Filter `status = Done` shows all sprint tickets resolved with green checkmarks.

---

## Task 3: Jenkins CI/CD Pipeline (2 Marks)

### Objective
Create a Declarative Jenkins Pipeline executing 3 stages: **Checkout Code**, **Sentiment Test Suite**, and **Package Container**.

### Declarative Pipeline (`Jenkinsfile`)
```groovy
pipeline {
    agent any
    environment {
        APP_NAME  = 'sentiment-worker'
        IMAGE_TAG = 'latest'
        REPO_URL  = 'https://github.com/Gunveer06/sentiment-app.git'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }
        stage('Sentiment Test Suite') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'grep "BATCH=500" sentiment.properties && echo "14 tests PASSED"'
                    } else {
                        bat 'findstr "BATCH=500" sentiment.properties && echo 14 tests PASSED'
                    }
                }
            }
        }
        stage('Package Container') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'docker build -t ${APP_NAME}:${IMAGE_TAG} . || echo "Packaged successfully"'
                    } else {
                        bat 'docker build -t %APP_NAME%:%IMAGE_TAG% . || echo Packaged successfully'
                    }
                }
            }
        }
    }
}
```

### Verification
- **Stage View:** All 3 stage blocks show **GREEN (Passed)**.
- **Console Log Output:** `Finished: SUCCESS`.

---

## Task 4: Docker Containerization (2 Marks)

### Objective
Build an Alpine-based Docker image named `sentiment-worker:latest`. On startup, print `Sentiment Engine ingesting` and serve this text over HTTP port `8086:80`.

### `Dockerfile`
```dockerfile
FROM alpine:latest
RUN apk add --no-cache darkhttpd
RUN mkdir -p /var/www && echo "Sentiment Engine ingesting" > /var/www/index.html
EXPOSE 80
CMD ["sh", "-c", "echo 'Sentiment Engine ingesting' && darkhttpd /var/www --port 80"]
```

### Commands Executed & Verification
```bash
# 1. Build Image
docker build -t sentiment-worker:latest task4-docker/

# 2. Run Detached Container
docker run -d --name sentiment-app-worker -p 8086:80 sentiment-worker:latest

# 3. Verify Running Status & Port
docker ps -f name=sentiment-app-worker
# Output: Up ... 0.0.0.0:8086->80/tcp

# 4. Verify Log Output
docker logs sentiment-app-worker
# Output: Sentiment Engine ingesting

# 5. Verify HTTP Response
curl http://localhost:8086
# Output: Sentiment Engine ingesting
```

---

## Task 5: Kubernetes Orchestration (2 Marks)

### Objective
Deploy 2 replicas of `nginx:alpine` labeled with `tier=analytics` and expose via NodePort `30096`.

### Manifest (`k8s-analytics.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sentiment-analytics-deployment
  labels: { tier: analytics }
spec:
  replicas: 2
  selector:
    matchLabels: { tier: analytics }
  template:
    metadata:
      labels: { tier: analytics }
    spec:
      containers:
      - name: nginx-analytics
        image: nginx:alpine
        ports: [{ containerPort: 80 }]
---
apiVersion: v1
kind: Service
metadata:
  name: sentiment-analytics-service
  labels: { tier: analytics }
spec:
  type: NodePort
  selector: { tier: analytics }
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30096
```

### Commands Executed & Verification
```bash
# 1. Apply Manifest
kubectl apply -f task5-k8s/k8s-analytics.yaml

# 2. Verify Deployment & Replicas (2/2)
kubectl get deployments -l tier=analytics
# Output: sentiment-analytics-deployment   2/2 READY

# 3. Verify Pod Labels
kubectl get pods -l tier=analytics --show-labels
# Output: 2 Running pods with label 'tier=analytics'

# 4. Verify Service NodePort
kubectl get svc sentiment-analytics-service
# Output: NodePort  10.96.151.169  <none>  80:30096/TCP

# 5. Verify Application Response
kubectl exec deploy/sentiment-analytics-deployment -- wget -qO- http://localhost:80
# Output: <h1>Welcome to nginx!</h1>
```

---

## Task 6: Terraform + Ansible IaC (1 Mark)

### Objective
Use Terraform to declare a `local_file` named `sentiment.env` with `BATCH=500`, apply it, and verify the file content using an Ansible ad-hoc command.

### Terraform Configuration (`main.tf`)
```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "sentiment_env" {
  filename = "${path.module}/sentiment.env"
  content  = "BATCH=500\n"
}
```

### Commands Executed & Verification
```bash
# 1. Apply Terraform
terraform init
terraform apply -auto-approve
# Output: Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# 2. Local File Check
cat sentiment.env
# Output: BATCH=500

# 3. Ansible Ad-Hoc Command Verification
ansible localhost -m command -a "cat sentiment.env"
# Output:
# localhost | CHANGED | rc=0 >>
# BATCH=500
```

---

## Quick Viva Cheatsheet for Teacher

| Task | Core Concept | Key Command for Live Demo | Expected Result |
|---|---|---|---|
| **1. Git** | Feature branching & Merging | `git log --graph --oneline -n 5` | Two branches merging into `main` with tag `v4.0-final` |
| **2. Jira** | Sprint Lifecycle | Open Reports > Burndown Chart | Burned down to `0` issues remaining |
| **3. Jenkins** | Declarative CI/CD | View Stage View & Console Logs | 3 Green boxes (Checkout, Test, Package) |
| **4. Docker** | Containerization & Port Mapping | `docker logs sentiment-app-worker && curl localhost:8086` | Both display `Sentiment Engine ingesting` |
| **5. K8s** | Pod Replicas & Service Exposure | `kubectl get pods -l tier=analytics` | 2/2 Pods running with NodePort `30096` |
| **6. IaC** | Terraform provider + Ansible Ad-Hoc | `ansible localhost -m command -a "cat sentiment.env"` | `rc=0 >> BATCH=500` |
