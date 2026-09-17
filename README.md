# DevSecOps Pipeline Demo (No Kubernetes)

A portfolio-ready, end-to-end DevSecOps pipeline that deploys straight to a
Docker host — no Kubernetes, Helm, or ArgoCD:

```
Developer -> Git -> Jenkins CI -> Maven -> SonarQube -> SAST/Dependency Scan
  -> Docker Build -> Trivy -> Nexus/Artifactory
  -> Deploy via Docker Compose over SSH (AWS EC2, provisioned by Terraform)
  -> Prometheus + Grafana -> ELK -> Alerts / Incident Response
```

## What's in here

| Folder        | Purpose |
|---------------|---------|
| `app/`        | Sample Spring Boot service (build target for the pipeline) |
| `ci/`         | `Jenkinsfile` implementing every CI/security/deploy stage |
| `deploy/`     | `deploy.sh` — SSHes into the app host and runs `docker compose up -d` |
| `docker-compose.yml` | The whole runtime stack: app, Prometheus, Grafana, Alertmanager, ELK |
| `terraform/`  | Provisions a VPC + single EC2 host with Docker pre-installed |
| `monitoring/` | Native Prometheus/Alertmanager config + a Grafana dashboard |
| `logging/`    | Filebeat/Logstash config for shipping container logs into Elasticsearch |

## How the pieces connect

1. **Developer** pushes code to **GitHub**.
2. **Jenkins** (`ci/Jenkinsfile`) checks it out and runs:
   `mvn verify` → **SonarQube** scan + quality gate → **OWASP Dependency-Check**
   (SAST/SCA) → `docker build` → **Trivy** image scan → push to **Nexus**.
3. On success, Jenkins calls `deploy/deploy.sh`, which SSHes into the app
   host, updates the image tag in `docker-compose.yml`, and runs
   `docker compose pull && docker compose up -d`. That's the entire
   "deployment" step — one host, one compose file, no cluster.
4. The host itself is an **AWS EC2** instance provisioned by `terraform/`
   (Docker installed via user-data on first boot).
5. **Prometheus** scrapes `/actuator/prometheus` from the app container;
   **Grafana** visualizes it; **Alertmanager** routes alerts to Slack/PagerDuty.
6. **Filebeat** tails the app container's Docker logs and ships them to
   **Logstash**, which forwards them into **Elasticsearch** (view in Kibana).

## Running it locally (learning setup)

1. **Build & containerize the app**
   ```bash
   cd app
   docker build -t nexus.example.com:5000/demo-app:latest .
   ```

2. **Scan it locally** (mirrors the Trivy CI stage)
   ```bash
   trivy image nexus.example.com:5000/demo-app:latest
   ```

3. **Bring up the whole stack with one command**
   ```bash
   cd ..
   docker compose up -d
   curl localhost:8080/                 # the app
   open http://localhost:9090           # Prometheus
   open http://localhost:3000           # Grafana (admin/changeme)
   open http://localhost:5601           # Kibana
   ```

4. **Provision the real AWS host when you're ready**
   ```bash
   cd terraform
   terraform init
   terraform apply -var="key_pair_name=your-ec2-keypair"
   ```
   Note the `app_host_public_ip` output, then point Jenkins'
   `DEPLOY_HOST` env var at it.

5. **Wire up Jenkins**
   Point a Jenkins instance (with SonarQube Scanner, Docker, Trivy, and
   OWASP Dependency-Check plugins installed) at this repo, add an SSH
   credential (`app-host-ssh-key`) for the EC2 host, and use
   `ci/Jenkinsfile` as a Pipeline-from-SCM job.

## Notes for a portfolio/demo write-up

- The **security gates are real and enforced**: the Quality Gate stage aborts
  the pipeline on a Sonar failure, Dependency-Check fails the build above
  CVSS 8, and Trivy exits non-zero on HIGH/CRITICAL vulnerabilities.
- This is intentionally the **simpler deployment model**: one host, one
  `docker-compose.yml`, deployed over SSH. It's the natural stepping stone
  before introducing Kubernetes — if you later want the GitOps/Helm/ArgoCD
  version of this same app, that's a straightforward next iteration.
- Trade-off to be upfront about in an interview: no rolling updates, no
  self-healing, no auto-scaling — `docker compose up -d` just recreates the
  container. That's the honest cost of skipping Kubernetes, and worth being
  able to articulate.
