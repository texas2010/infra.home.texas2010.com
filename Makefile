## You can edit this service name
SERVICE_TITLE="Texas2010 Home Infrastructure"
SERVICE_NAME=infra-home-texas2010-com


## do not edit bottom to down.
.DEFAULT_GOAL := help
COMPOSE_FILE ?= docker-compose.yml
SYSTEMD_SERVICE_FILE=$(SERVICE_NAME).service

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

docker-up: ## Start Docker containers
	@echo "Starting containers using $(COMPOSE_FILE)..."
	docker compose -f $(COMPOSE_FILE) up -d

docker-start: docker-up ## Start Docker containers

docker-down: ## Stop Docker containers
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

docker-stop: docker-down ## Stop Docker containers

docker-restart: ## Restart Docker containers
	@echo "Restarting containers..."
	docker compose -f $(COMPOSE_FILE) down
	docker compose -f $(COMPOSE_FILE) up -d

docker-logs: ## Show Docker containers logs
	@echo "Showing logs (Ctrl+C to exit)..."
	docker compose -f $(COMPOSE_FILE) logs -f

docker-ps: ## List running Docker containers
	@echo "Listing running containers..."
	docker compose -f $(COMPOSE_FILE) ps

docker-clean: ## Remove Docker containers, volumes, and orphans
	@echo "Removing containers, volumes, and orphans..."
	docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	docker system prune -f

docker-rebuild: ## Rebuild images without cache
	@echo "Rebuilding images without cache..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d

update-all: ## Stop, git pull, rebuild, and start
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down
	@echo "Pulling latest code from Git..."
	git pull
	@echo "Rebuilding images..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d

create-systemd-service-file: ## Builds a .service file using the current directory
	@mkdir -p logs
	@echo "Creating Systemd Service File..."
	@echo "[Unit]" > $(SYSTEMD_SERVICE_FILE)
	@echo "Description=$(SERVICE_TITLE)" >> $(SYSTEMD_SERVICE_FILE)
	@echo "After=network.target docker.service" >> $(SYSTEMD_SERVICE_FILE)
	@echo "Requires=docker.service" >> $(SYSTEMD_SERVICE_FILE)
	@echo "" >> $(SYSTEMD_SERVICE_FILE)
	@echo "[Service]" >> $(SYSTEMD_SERVICE_FILE)
	@echo "Type=oneshot" >> $(SYSTEMD_SERVICE_FILE)
	@echo "RemainAfterExit=yes" >> $(SYSTEMD_SERVICE_FILE)
	@echo "WorkingDirectory=$(PWD)" >> $(SYSTEMD_SERVICE_FILE)
	@echo "ExecStart=/usr/bin/docker compose up -d" >> $(SYSTEMD_SERVICE_FILE)
	@echo "ExecStop=/usr/bin/docker compose down" >> $(SYSTEMD_SERVICE_FILE)
	@echo "StandardOutput=append:$(PWD)/logs/service.log" >> $(SYSTEMD_SERVICE_FILE)
	@echo "StandardError=append:$(PWD)/logs/service-error.log" >> $(SYSTEMD_SERVICE_FILE)
	@echo "" >> $(SYSTEMD_SERVICE_FILE)
	@echo "[Install]" >> $(SYSTEMD_SERVICE_FILE)
	@echo "WantedBy=multi-user.target" >> $(SYSTEMD_SERVICE_FILE)
	@echo "Created: $(SYSTEMD_SERVICE_FILE)"

install-systemd-service: create-systemd-service-file ## Moves it into /etc/systemd/system, reloads, enables, and starts it
	@echo "Installing Systemd Service..."
	sudo mv $(SYSTEMD_SERVICE_FILE) /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable $(SERVICE_NAME)
	sudo systemctl start $(SERVICE_NAME)

systemd-uninstall: ## Stops, disables, and removes the unit
	@echo "Uninstalling Systemd Service..."
	sudo systemctl stop $(SERVICE_NAME) || true
	sudo systemctl disable $(SERVICE_NAME) || true
	sudo rm -f /etc/systemd/system/$(SYSTEMD_SERVICE_FILE)
	sudo systemctl daemon-reload
	@echo "Removed: $(SYSTEMD_SERVICE_FILE)"


systemd-status: ## Shows current service status
	@echo "Checking Systemd Service..."
	sudo systemctl status $(SERVICE_NAME)

systemd-restart: ## Restarts via systemd
	@echo "Restarting Systemd Service..."
	sudo systemctl restart $(SERVICE_NAME)

systemd-stop: ## Stops via systemd
	@echo "Stopping Systemd Service..."
	sudo systemctl stop $(SERVICE_NAME)

systemd-enable: ## Enable Systemd Service
	@echo "Enable Systemd Service..."
	sudo systemctl enable $(SERVICE_NAME)

systemd-disable: ## Disable Systemd Service
	@echo "Disable Systemd Service..."
	sudo systemctl disable $(SERVICE_NAME)