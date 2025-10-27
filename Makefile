.DEFAULT_GOAL := help
.PHONY: help up start down stop restart logs ps clean rebuild update
COMPOSE_FILE ?= docker-compose.yml

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

up: ## Start containers
	@echo "Starting containers using $(COMPOSE_FILE)..."
	docker compose -f $(COMPOSE_FILE) up -d

start: up ## Start containers

down: ## Stop containers
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

stop: down ## Stop containers

restart: ## Restart containers
	@echo "Restarting containers..."
	docker compose -f $(COMPOSE_FILE) down
	docker compose -f $(COMPOSE_FILE) up -d

logs: ## Show container logs
	@echo "Showing logs (Ctrl+C to exit)..."
	docker compose -f $(COMPOSE_FILE) logs -f

ps: ## List running containers
	@echo "Listing running containers..."
	docker compose -f $(COMPOSE_FILE) ps

clean: ## Remove containers, volumes, and orphans
	@echo "Removing containers, volumes, and orphans..."
	docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	docker system prune -f

rebuild: ## Rebuild images without cache
	@echo "Rebuilding images without cache..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d

update: ## Stop, git pull, rebuild, and start
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down
	@echo "Pulling latest code from Git..."
	git pull
	@echo "Rebuilding images..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d