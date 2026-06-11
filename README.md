<p align="center">
  <img alt="Proxmox VE 9" src="https://img.shields.io/badge/Proxmox-VE_9-E57000?logo=proxmox&logoColor=white">
  <img alt="Ubuntu 24.04 LXC" src="https://img.shields.io/badge/Ubuntu-24.04_LXC-E95420?logo=ubuntu&logoColor=white">
  <img alt="Docker Compose" src="https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white">
  <img alt="Grafana" src="https://img.shields.io/badge/Grafana-Provisioned-F46800?logo=grafana&logoColor=white">
  <img alt="Prometheus" src="https://img.shields.io/badge/Prometheus-15s-E6522C?logo=prometheus&logoColor=white">
  <img alt="Alertmanager" src="https://img.shields.io/badge/Alertmanager-Alerts-E6522C?logo=prometheus&logoColor=white">
  <img alt="Blackbox Exporter" src="https://img.shields.io/badge/Blackbox-HTTP%2FSSL-111827?logo=prometheus&logoColor=white">
  <img alt="cAdvisor" src="https://img.shields.io/badge/cAdvisor-Containers-326CE5?logo=kubernetes&logoColor=white">
  <img alt="IaC" src="https://img.shields.io/badge/IaC-Ready-181717?logo=github&logoColor=white">
  <img alt="Retention" src="https://img.shields.io/badge/Retention-15d-64748B">
</p>

# Proxmox Monitoring Stack

Self-hosted observability stack for Proxmox VE, LXC, VMs, Docker workloads, and public endpoint checks.

## Repository Tree

```text
.
├── .env.example
├── .gitignore
├── Makefile
├── README.md
├── configs
│   ├── alertmanager
│   │   └── alertmanager.yml
│   ├── blackbox
│   │   └── blackbox.yml
│   ├── prometheus
│   │   ├── prometheus.yml
│   │   ├── rules
│   │       └── alerts.yml
│   │   └── targets
│   │       └── .gitkeep
│   └── proxmox-exporter
│       └── pve.yml.example
├── dashboards
│   └── grafana
│       ├── blackbox-exporter.json
│       ├── docker-cadvisor.json
│       ├── infrastructure-overview.json
│       ├── linux-node-exporter.json
│       └── proxmox.json
├── docker-compose.yml
├── scripts
│   └── bootstrap-ubuntu.sh
└── provisioning
    └── grafana
        ├── dashboards
        │   └── dashboards.yml
        └── datasources
            └── prometheus.yml
```

## Setup Commands

```bash
./scripts/bootstrap-ubuntu.sh
```

## Deployment Commands

```bash
make deploy
```

## Access Policy

```text
Grafana: LAN-facing by default
Prometheus: localhost only
Alertmanager: localhost only
Blackbox Exporter: localhost only
Proxmox Exporter: localhost only
cAdvisor: localhost only
```

## Verification Commands

```bash
make verify
make autostart-status
```

## Proxmox Exporter

```bash
./scripts/configure-proxmox-exporter.sh 192.168.1.1 prometheus@pve monitoring 'TOKEN_SECRET' false
docker compose up -d --force-recreate proxmox-exporter prometheus
```

## Agent Onboarding

On a Linux agent machine:

```bash
curl -fsSLO https://raw.githubusercontent.com/jotyprokash/Infrastructure-Monitoring-Platform/main/scripts/install-agent.sh
chmod +x install-agent.sh
sudo INSTALL_NODE_EXPORTER=true INSTALL_CADVISOR=false ./install-agent.sh
```

On a Docker agent machine:

```bash
curl -fsSLO https://raw.githubusercontent.com/jotyprokash/Infrastructure-Monitoring-Platform/main/scripts/install-agent.sh
chmod +x install-agent.sh
sudo INSTALL_NODE_EXPORTER=true INSTALL_CADVISOR=true CADVISOR_PORT=8081 ./install-agent.sh
```

On the monitoring server:

```bash
cp -n inventory/agents.yml.example inventory/agents.yml
make onboard-agent
make verify
```
