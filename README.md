<p align="center">
  <img alt="Proxmox VE 9" src="https://img.shields.io/badge/Proxmox-VE_9-E57000?style=for-the-badge&logo=proxmox&logoColor=white">
  <img alt="Ubuntu 24.04 LXC" src="https://img.shields.io/badge/Ubuntu-24.04_LXC-E95420?style=for-the-badge&logo=ubuntu&logoColor=white">
  <img alt="Docker" src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white">
  <img alt="Grafana" src="https://img.shields.io/badge/Grafana-Provisioned-F46800?style=for-the-badge&logo=grafana&logoColor=white">
  <img alt="Prometheus" src="https://img.shields.io/badge/Prometheus-15s_Scrape-E6522C?style=for-the-badge&logo=prometheus&logoColor=white">
  <img alt="Alertmanager" src="https://img.shields.io/badge/Alertmanager-Ruleset-E6522C?style=for-the-badge&logo=prometheus&logoColor=white">
  <img alt="Blackbox Exporter" src="https://img.shields.io/badge/Blackbox-HTTP_SSL_Checks-111827?style=for-the-badge&logo=prometheus&logoColor=white">
  <img alt="cAdvisor" src="https://img.shields.io/badge/cAdvisor-Container_Metrics-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white">
  <img alt="Infrastructure as Code" src="https://img.shields.io/badge/IaC-GitHub_Ready-181717?style=for-the-badge&logo=github&logoColor=white">
  <img alt="Self hosted" src="https://img.shields.io/badge/Self--Hosted-Observability-0F766E?style=for-the-badge">
  <img alt="Retention" src="https://img.shields.io/badge/Retention-15_Days-64748B?style=for-the-badge">
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
