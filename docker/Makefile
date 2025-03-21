#!/usr/bin/make -f

# we use same makefile in root and ./docker
DOCKER_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER = docker
DOCKER_COMPOSE = $(DOCKER) compose -f $(DOCKER_DIR)/docker-compose.yml

SRC_DIR = /opencca
SHELL_HISTORY = $(DOCKER_DIR)/.bash_history $(DOCKER_DIR)/.fish_history
CACHE_DIR = $(DOCKER_DIR)/.cache
SHELL := /bin/bash

SERVICE_URL = ghcr.io/opencca/opencca-build:latest
SERVICE = opencca-build

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  build         - Build the Docker image locally"
	@echo "  pull          - Pull a prebuilt image"
	@echo "  start         - Start the interactive development container"
	@echo "  enter         - Enter the running container"
	@echo "  run CMD='...' - Run a command inside the container"
	@echo "  stop          - Stop the container"
	@echo "  clean         - Remove the container and unused images"


.PHONY: setup
setup:
	touch $(SHELL_HISTORY)
	mkdir -p $(CACHE_DIR)

.PHONY: pull
pull: setup
	$(DOCKER) pull $(SERVICE_URL)

.PHONY: build
build: setup
	-@docker image rm $(SERVICE_URL) &> /dev/null
	$(DOCKER_COMPOSE) build $(SERVICE)

.PHONY: start
start: setup
	$(DOCKER_COMPOSE) up -d $(SERVICE)

.PHONY: enter
enter:
	$(DOCKER_COMPOSE) exec $(SERVICE) bash

.PHONY: run
run:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) $(CMD)

.PHONY: stop
stop:
	-$(DOCKER_COMPOSE) stop $(SERVICE)

.PHONY: clean
clean:
	docker rm -f $(SERVICE) $(SERVICE_URL) || true
	docker volume rm $$(docker volume ls -qf dangling=true) &> /dev/null || true
