# DevSecOps Flask Application Beginner friendly project

A production-grade **DevSecOps project** demonstrating secure CI/CD practices using:
- Static Analysis (SAST)
- Secret Scanning
- Container Security
- Dynamic Application Security Testing (DAST)
- Kubernetes Deployment

---

## 🚀 Tech Stack

| Layer | Tools |
|-----|------|
| Backend | Python, Flask |
| CI/CD | GitHub Actions |
| SAST | Semgrep |
| Secrets Scan | Gitleaks |
| Container | Docker |
| Image Scan | Trivy |
| DAST | OWASP ZAP |
| Registry | GitHub Container Registry (GHCR) |
| Orchestration | Kubernetes |

---

## 📁 Project Structure

```

.
├── app/
│   ├── main.py
│   └── requirements.txt
├── tests/
│   └── test_app.py
├── kubernetes/
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
└── .github/workflows/devsecops.yml

````

---

## 🐳 Docker Setup

Build image locally:
```bash
docker build -t flask-app .
````

Run container:

```bash
docker run -p 5000:5000 flask-app
```

---

## 🔐 CI/CD Security Pipeline

### ✔ Pipeline Stages

1. **Unit Testing**
2. **SAST (Semgrep)**
3. **Secret Scanning (Gitleaks)**
4. **Docker Build**
5. **Image Vulnerability Scan (Trivy)**
6. **DAST (OWASP ZAP)**
7. **Push Image to GHCR**
8. **Agro CD fetch latest image from GHRC**
8. **Update Kubernetes Deployment**

---

## 🧪 DAST Testing (OWASP ZAP)

* Application is started inside Docker
* ZAP performs **baseline scan**
* Detects runtime vulnerabilities
* Findings visible in CI logs

Example scan:

```bash
zap-baseline.py -t http://localhost:5000
```

---

## ☸️ Kubernetes Deployment

Apply Kubernetes manifests:

```bash
kubectl apply -f kubernetes/
```

Check pods:

```bash
kubectl get pods
```

---

## 🔐 GHCR Authentication (Kubernetes)

Create image pull secret:

```bash
kubectl create secret docker-registry github-container-registry \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-token> \
  --docker-email=<email>
```

---

## 🧠 DevSecOps Highlights

✔ Shift-left security
✔ Automated security gates
✔ Immutable container images
✔ GitOps-style Kubernetes deployment
✔ End-to-end CI/CD security coverage

---

## 📌 More features can be added 

* Enforce ZAP failure gates
* Add Ingress + TLS
* Add HPA (auto-scaling)
* Add monitoring (Prometheus / Grafana)


