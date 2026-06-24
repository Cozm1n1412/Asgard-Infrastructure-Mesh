# Asgard Infra Mesh

Automated Infrastructure as Code (IaC) mesh environment orchestrating microservices and persistence layers locally.

## Architecture Components
- **Core Network:** Isolated Docker Bridge Mesh (`asgard_isolated_mesh`)
- **Database Layer:** PostgreSQL 15 (`asgard_postgres_storage`) with persistent volume
- **Caching Layer:** Redis 7 (`asgard_redis_state`) with persistent volume
- **Telemetry Service:** Gungnir API & Gungnir Live Metrics Collector
- **Guardian Service:** Muninn Sentry Background Worker with active Telegram Alerting

## Technology Stack
- **OS:** Arch Linux (Bare-metal host)
- **Orchestration:** Terraform (v1.15.2)
- **Runtime:** Docker Engine & Linux Native Sockets
- **Backend:** Python 3.11 / FastAPI

## How to Deploy Locally
1. Initialize variables in `variables.tf`.
2. Run safety inspection: `terraform plan`
3. Deploy architecture: `terraform apply`
