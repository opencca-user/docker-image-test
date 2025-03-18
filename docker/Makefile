#!/usr/bin/make -f

# we use same makefile in root and ./docker
DOCKER_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER_COMPOSE = docker compose -f $(DOCKER_DIR)/docker-compose.yml
SERVICE = opencca-build
SRC_DIR = /opencca
SHELL_HISTORY = $(DOCKER_DIR)/.bash_history $(DOCKER_DIR)/.fish_history
CACHE_DIR = $(DOCKER_DIR)/.cache
SHELL := /bin/bash

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  build         - Build the Docker image"
	@echo "  start         - Start the interactive development container"
	@echo "  enter         - Enter the running container"
	@echo "  run CMD='...' - Run a command inside the container"
	@echo "  stop          - Stop the container"
	@echo "  clean         - Remove the container and unused images"

.PHONY: build
build:
	touch $(SHELL_HISTORY)
	mkdir -p $(CACHE_DIR)
	$(DOCKER_COMPOSE) build

.PHONY: start
start:
	$(DOCKER_COMPOSE) up -d

.PHONY: enter
enter:
	$(DOCKER_COMPOSE) exec $(SERVICE) bash

.PHONY: run
run:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) $(CMD)

.PHONY: stop
stop:
	$(DOCKER_COMPOSE) stop

.PHONY: clean
clean:
	docker rm -f $(SERVICE) || true
	docker volume rm $$(docker volume ls -qf dangling=true) || true
