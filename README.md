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
│   │   └── rules
│   │       └── alerts.yml
│   └── proxmox-exporter
│       └── pve.yml
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
chmod +x scripts/bootstrap-ubuntu.sh
make bootstrap
```

## Deployment Commands

```bash
make deploy
```

## Verification Commands

```bash
make verify
```
