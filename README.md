<!-- Banner -->
![DevSecOps Banner](images/devsecops_banner.png)

# 🚀 DevSecOps Web UI — CI/CD + Container Security + AWS EC2 + Kind (Kubernetes) + Argo CD (GitOps)

---

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Repo Structure](#repo-structure)
- [App Features](#app-features)
- [UI Preview](#ui-preview)
- [Local Installation & Setup](#local-installation--setup)
- [Docker Build & Local Testing](#docker-build--local-testing)
- [DevSecOps Pipeline](#devsecops-pipeline-step-by-step)
- [Images & Screenshots](#images--screenshots)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

---

## 🗺️ Project Overview

- **App:** Simple Flask web app with UI and API endpoints
- **Pipeline:** GitHub Actions → Security Scans → Container Registry → AWS EC2 → Kubernetes (kind) → Argo CD (GitOps)
- **Goal:** Learn, build, and deploy like a real DevSecOps team!

---

## 📂 Repo Structure

```
app/                  # Flask app source
  templates/          # HTML UI
  static/             # CSS
tests/                # Unit tests
Dockerfile            # Container build instructions
.github/workflows/    # GitHub Actions pipeline
kubernetes/           # Kubernetes manifests (Deployment/Service)
images/               # Supporting screenshots & diagrams
```

---

## 🌐 App Features

| Route           | Method | Description                                 |
|-----------------|--------|---------------------------------------------|
| `/`             | GET    | Serves the UI page (index.html)             |
| `/api/status`   | GET    | Returns JSON status (used by UI button)     |
| `/health`       | GET    | Health endpoint for readiness checks        |

> **Why `/health`?**  
> Used by load balancers, Kubernetes probes, and uptime monitors.

---

## 🖼️ UI Preview

*The web UI running locally at http://localhost:5000*

---

## 🚦 DevSecOps Pipeline: Step-by-Step

### A. 📝 Git Workflow

1. **Commit & Push Changes**
   ```bash
   git add .
   git commit -m "describe what you changed"
   git push origin main
   ```
2. **Sync with Remote (Rebase)**
   ```bash
   git pull --rebase origin main
   ```
   > _Keeps history clean by replaying your commits on top of the latest remote changes._

![GitHub Commits](images/github_commits.png)

---

## 🏗️ Local Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
```

### 2. Install Python Dependencies
```bash
cd app
pip install -r requirements.txt
```

### 3. Run the Flask App Locally
```bash
python main.py
```
- Access the app at: [http://localhost:5000](http://localhost:5000)

### 4. Run Unit Tests
```bash
pytest ../tests
```

---

### B. 🔐 GitHub Token & Repo Secrets

- **Never share your personal access token!**  
  If exposed, revoke it immediately.

#### 1. Create a GitHub Personal Access Token (PAT)
- Go to: GitHub → Settings → Developer settings → Personal access tokens
- Recommended scopes:
  - `read:packages`
  - `write:packages`
  - `repo` (if needed)

![Token Scopes](images/token_scopes.png)

#### 2. Add Token to Repo Secrets
- Go to: Repo → Settings → Secrets and variables → Actions
- Add:
  - `GHCR_TOKEN`
  - `GHCR_USERNAME`

![Repo Secrets](images/repo_secrets.png)

---

### C. ☁️ AWS EC2 Setup

#### 1. Launch EC2 Instance
- **Name:** devsecops-demo
- **OS:** Ubuntu 22.04
- **Type:** t3.medium
- **Storage:** 20–30 GB
- **Security Group:** Allow SSH (22), HTTP (80), and custom ports (5000, 30080, 9000)

![EC2 Instance](images/ec2_instance.png)
![Security Group](images/security_group.png)

#### 2. SSH into EC2
```bash
ssh -i ~/Documents/devsecops.pem ubuntu@<EC2_PUBLIC_IP>
```

---

### D. 🐳 Install Docker on EC2

```bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
docker --version
docker ps
```

---

### E. 📦 Run the Container

1. **Login to GHCR (if private):**
   ```bash
   docker login ghcr.io
   ```
2. **Run the app:**
   ```bash
   docker run -d -p 5000:5000 ghcr.io/<github-username>/<image-name>:latest
   ```
3. **Check:**
   ```bash
   docker ps
   curl http://localhost:5000/health
   ```

![Docker Running](images/docker_running.png)
![Health Check](images/health_check.png)

---

### F. ☸️ Install kind (Kubernetes in Docker)

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
kind create cluster --name devsecops-demo
```

![Kind Cluster](images/kind_cluster.png)

---

### G. 🛠️ Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl config current-context
kubectl get nodes
```

![kubectl Nodes](images/kubectl_nodes.png)

---

### H. 🚀 Install Argo CD (GitOps)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd -w
```

![ArgoCD Pods](images/argocd_pods.png)

#### Access Argo CD UI

```bash
kubectl get svc -n argocd
kubectl port-forward svc/argocd-server -n argocd 9000:443 --address 0.0.0.0
```
- Open: `https://<EC2_PUBLIC_IP>:9000`

![ArgoCD Login](images/argocd_login.png)

#### Get Argo CD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

- **Username:** admin
- **Password:** (output above)

![ArgoCD Dashboard](images/argocd_dashboard.png)

---

### I. 🔑 Kubernetes Image Pull Secret (for GHCR)

```bash
export GHCR_TOKEN="paste_token_here"
kubectl create secret docker-registry github-container-registry \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password="$GHCR_TOKEN" \
  --docker-email=<email>
unset GHCR_TOKEN
```

![K8s Secret](images/k8s_secret.png)

---

### J. 📦 Deploy with Argo CD

- Add your Kubernetes manifests to `kubernetes/`
- Create an Argo CD Application pointing to that folder
- Argo will sync automatically

![ArgoCD Synced](images/argocd_synced.png)

---

## 📸 Images & Screenshots

Below are key screenshots and diagrams referenced throughout the documentation, following the image naming convention in the `images/` folder:

- ![DevSecOps Banner](images/devsecops_banner.png)
- ![UI Screenshot](images/ui_screenshot.png)
- ![CI/CD Pipeline](images/ci_cd_pipeline.png)
- ![AWS Config](images/aws_config.png)
- ![AWS Security Rules](images/aws_security_rules.png)
- ![AWS SSH](images/aws_ssh.png)
- ![AWS SSH 2](images/aws_ssh2.png)
- ![AWS Connect](images/aws_connect.png)
- ![AWS Docker](images/aws_docker.png)
- ![AWS GHCR Login](images/aws_ghcrlogin.png)
- ![EC2 Instance](images/ec2_instance.png)
- ![ArgoCD Dashboard](images/argocd_dashboard.png)
- ![ArgoCD Login](images/argocd_login.png)
- ![ArgoCD Pods Running](images/argocd_pods_running_successfuly.png)
- ![ArgoCD Pod Health](images/argocd_pod_health.png)
- ![ArgoCD Config](images/argocd_config.png)
- ![ArgoCD Config 2](images/argocd_config2.png)
- ![ArgoCD Password](images/argocd _password.png)
- ![Config Kubectl to Pull Images](images/config_kubectl_to_oull_images.png)
- ![Running App on AWS Docker](images/running app on aws_docker.png)

---

## 🐳 Docker Build & Local Testing

### 1. Build the Docker Image
```bash
docker build -t devsecops-webui:latest .
```

### 2. Run the Docker Container
```bash
docker run -d -p 5000:5000 devsecops-webui:latest
```
- Access the app at: [http://localhost:5000](http://localhost:5000)

### 3. Health Check
```bash
curl http://localhost:5000/health
```

---

## 🛠️ Troubleshooting

1. **Docker login fails:**
   - Check token scopes and registry URL
2. **Argo CD UI not reachable:**
   - Check port-forward and EC2 security group
3. **Kubernetes can’t pull image:**
   - Ensure secret exists and is referenced in your Deployment

For more help, see [GitHub Discussions](https://github.com/<your-username>/<repo-name>/discussions) or open an issue.

---

## 🏷️ Badges

[![Build](https://img.shields.io/github/workflow/status/cybraman/devsecops-project/CI?style=for-the-badge)](https://github.com/cybraman/devsecops-project/actions)
[![License](https://img.shields.io/github/license/cybraman/devsecops-project?style=for-the-badge)](https://github.com/cybraman/devsecops-project/blob/main/LICENSE)
[![Contributors](https://img.shields.io/github/contributors/cybraman/devsecops-project?style=for-the-badge)](https://github.com/cybraman/devsecops-project/graphs/contributors)
[![Issues](https://img.shields.io/github/issues/cybraman/devsecops-project?style=for-the-badge)](https://github.com/cybraman/devsecops-project/issues)
[![Stars](https://img.shields.io/github/stars/cybraman/devsecops-project?style=for-the-badge)](https://github.com/cybraman/devsecops-project/stargazers)

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository ([cybraman/devsecops-project](https://github.com/cybraman/devsecops-project))
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m "Add your feature"`)
4. Push to your branch (`git push origin feature/your-feature`)
5. Open a Pull Request ([PRs](https://github.com/cybraman/devsecops-project/pulls))

### 📋 Issue & PR Templates
- Use the provided issue template for bug reports and feature requests ([Issues](https://github.com/cybraman/devsecops-project/issues))
- Use the PR template for clear, descriptive pull requests ([PRs](https://github.com/cybraman/devsecops-project/pulls))

---

## 🛠️ Troubleshooting

For more help, see [GitHub Discussions](https://github.com/cybraman/devsecops-project/discussions) or open an [issue](https://github.com/cybraman/devsecops-project/issues).

---

## 📚 Resources

- [Project Repository](https://github.com/cybraman/devsecops-project)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker](https://docs.docker.com/)
- [Kubernetes](https://kubernetes.io/docs/)
- [Argo CD](https://argo-cd.readthedocs.io/en/stable/)

---

## 🏆 License

MIT License — see [LICENSE](https://github.com/cybraman/devsecops-project/blob/main/LICENSE) for details.

---

> _Happy DevSecOps-ing!_ 🚀
