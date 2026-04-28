\⚡ n8n — Workflow Automation
n8n — это мощный инструмент для автоматизации задач , который позволяет связывать разные сервисы через визуальный редактор.

# Docker Swarm Infrastructure 🐳  Мониторинг и оркестрация

## 📁 Project Structure
├── scripts/
│ ├── set-n8n-domain.sh # Смена домена для n8n
│ ├── set-grafana-domain.sh # Смена домена для Grafana
│ └── set-all-domains.sh # Смена всех доменов (опционально)
├── n8n/
│ └── n8n-stack.yml # 🧩 n8n + PostgreSQL + Redis + Traefik
├── grafana-prometheus/
│ ├── config-prometheus.yml # 📊 Конфигурация Prometheus
│ └── prometheus-stack.yaml # 🖥️ Стек мониторинга (Prometheus + Grafana)
└── README.md

## ⚙️ Domain Configuration

Before deployment, you need to replace the default domains with your own.

### 🔧 Automatic Domain Replacement Scripts

| Script | What it does |
|--------|--------------|
| `scripts/set-n8n-domain.sh` | Changes domain in `n8n/n8n-stack.yml` |
| `scripts/set-grafana-domain.sh` | Changes domain in `grafana-prometheus/prometheus-stack.yaml` |

### 📝 Usage

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Show current n8n domain
./scripts/set-n8n-domain.sh --show

# Set new domain for n8n
./scripts/set-n8n-domain.sh n8n.mycompany.ru

# Show current Grafana domain
./scripts/set-grafana-domain.sh --show

# Set new domain for Grafana
./scripts/set-grafana-domain.sh grafana.mycompany.ru


In the manifest file : n8n-stack.yml and prometheus-stack.yaml

## ⚠️  REPLACE WITH YOUR DOMAIN  ⚠️
## ============================================
Configuration Details: 
* **n8n domain:** n8n.expert-only.ru
* **WEBHOOK_URL:** https://your-domain.com
* **Grafana domain:** grafana.expert-only.ru


Production-ready Docker Swarm стек для запуска **n8n** and **monitoring** (Prometheus + Grafana + экспортеры).
## 🚀 Getting Started
```bash
echo "pass" | docker secret create postgres_password -
echo "pass" | docker secret create n8n_password -
echo "login" | docker secret create n8n_user -
openssl rand -hex 32 | docker secret create n8n_encryption_key - 
 ```


### Prerequisites
- Docker Swarm cluster initialized
- Overlay networks created:
  ```bash
  docker network create --driver overlay traefik-public
  docker network create --driver overlay monitoring
  docker network create --driver overlay n8n-net
 


📚 Resourcе
- [📖 n8n Documentation](https://docs.n8n.io)  
- [📊 Prometheus Documentation](https://prometheus.io/docs)
- [📈 Grafana Documentation](https://grafana.com/docs)
- [🔄 Traefik Documentation](https://doc.traefik.io/traefik)
