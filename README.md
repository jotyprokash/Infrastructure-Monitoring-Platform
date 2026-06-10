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

## Agent Onboarding

```bash
curl -fsSLO https://raw.githubusercontent.com/jotyprokash/Infrastructure-Monitoring-Platform/main/scripts/install-node-exporter.sh
chmod +x install-node-exporter.sh
sudo ./install-node-exporter.sh
```

```bash
curl -fsSLO https://raw.githubusercontent.com/jotyprokash/Infrastructure-Monitoring-Platform/main/scripts/install-cadvisor-agent.sh
chmod +x install-cadvisor-agent.sh
sudo ./install-cadvisor-agent.sh
```

```text
./scripts/register-target.sh <job> <ip:port> <role> <name>
```

```bash
./scripts/register-target.sh node-exporter-proxmox-host 192.168.1.2:9100 proxmox-host pve01
./scripts/register-target.sh node-exporter-lxc 192.168.1.30:9100 lxc lxc-30
./scripts/register-target.sh node-exporter-vms 192.168.1.40:9100 vm defectdojo
./scripts/register-target.sh cadvisor-defectdojo-vm 192.168.1.40:8080 defectdojo-vm defectdojo
```
