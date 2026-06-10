COMPOSE=docker compose

.PHONY: bootstrap init deploy up down restart pull logs ps validate verify autostart-status reload-prometheus reload-alertmanager clean agent-node agent-cadvisor

bootstrap:
	./scripts/bootstrap-ubuntu.sh

init:
	test -f .env || cp .env.example .env
	test -f configs/proxmox-exporter/pve.yml || cp configs/proxmox-exporter/pve.yml.example configs/proxmox-exporter/pve.yml

deploy: init validate pull up ps

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

pull:
	$(COMPOSE) pull

logs:
	$(COMPOSE) logs -f --tail=200

ps:
	$(COMPOSE) ps

validate:
	$(COMPOSE) config

verify:
	$(COMPOSE) ps
	curl -fsS http://localhost:$${PROMETHEUS_HTTP_PORT:-9090}/-/healthy
	curl -fsS http://localhost:$${ALERTMANAGER_HTTP_PORT:-9093}/-/healthy
	curl -fsS http://localhost:$${BLACKBOX_HTTP_PORT:-9115}/-/healthy
	curl -fsS http://localhost:$${PROXMOX_EXPORTER_HTTP_PORT:-9221}/metrics
	curl -fsS http://localhost:$${CADVISOR_HTTP_PORT:-8080}/metrics
	curl -fsS http://localhost:$${GRAFANA_HTTP_PORT:-3000}/api/health
	curl -fsS "http://localhost:$${PROMETHEUS_HTTP_PORT:-9090}/api/v1/targets"
	curl -fsS "http://localhost:$${PROMETHEUS_HTTP_PORT:-9090}/api/v1/rules"

autostart-status:
	systemctl is-enabled docker
	systemctl is-active docker
	$(COMPOSE) ps

agent-node:
	./scripts/install-node-exporter.sh

agent-cadvisor:
	./scripts/install-cadvisor-agent.sh

reload-prometheus:
	curl -fsS -X POST http://localhost:$${PROMETHEUS_HTTP_PORT:-9090}/-/reload

reload-alertmanager:
	curl -fsS -X POST http://localhost:$${ALERTMANAGER_HTTP_PORT:-9093}/-/reload

clean:
	$(COMPOSE) down --remove-orphans
