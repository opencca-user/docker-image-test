#!/usr/bin/make -f

#
# Opencca Build Entrypoint
# TLDR; make pull && make start && make enter
# requires make and docker preinstalled
#

DOCKER_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER = docker
DOCKER_COMPOSE = $(DOCKER) compose -f $(DOCKER_DIR)/docker-compose.yml

SRC_DIR = /opencca
SHELL_HISTORY = $(DOCKER_DIR)/.bash_history $(DOCKER_DIR)/.fish_history
CACHE_DIR = $(DOCKER_DIR)/.cache
SHELL = /bin/bash

#
# Naming conventions
# For now we tag the runner with :latest and the 7-letter sha
# We always pull the :latest build, overwrite if needed
#
VERSION_PULL = latest
VERSION_PUSH = latest

# XXX: These names must match in the compose file
SERVICE_URL = ghcr.io/opencca/opencca-build
SERVICE = opencca-build

BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_REF ?= $(shell git rev-parse HEAD)
BUILD_VERSION ?= $(shell git rev-parse --short HEAD)

CACHE ?=0

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
	$(DOCKER) pull $(SERVICE_URL):$(VERSION_PULL)

.PHONY: build
build: setup
ifeq ($(CACHE),0)
	-@$(DOCKER) image rm $(SERVICE_URL):latest &> /dev/null || true # XXX: Remove explicitly
	-@$(DOCKER) image rm $(SERVICE_URL):$(VERSION_PUSH) &> /dev/null || true
	-@$(DOCKER) image rm $(SERVICE_URL):$(BUILD_VERSION) &> /dev/null || true
else
	@echo "Caching enabled. skipping building from scratch"
endif

	$(DOCKER) buildx build \
		--file $(DOCKER_DIR)/Dockerfile \
		--tag $(SERVICE_URL):$(VERSION_PUSH) \
		--tag $(SERVICE_URL):$(BUILD_VERSION) \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg BUILD_REF="$(BUILD_REF)" \
		--build-arg BUILD_VERSION="$(BUILD_VERSION)" \
		--load  \
		$(DOCKER_DIR)/..

.PHONY: start
start: setup
	$(DOCKER_COMPOSE) up -d $(SERVICE)

.PHONY: enter
enter:
	$(DOCKER_COMPOSE) exec $(SERVICE) bash

.PHONY: run
run:
	$(DOCKER_COMPOSE) run --rm $(SERVICE) $(CMD)

# XXX: For CI: Run a script inside the container
.PHONY: run-script
run-script:
	@if [ -z "$(SCRIPT)" ]; then \
		echo "Error: SCRIPT variable not set."; \
		exit 1; \
	fi
	$(DOCKER_COMPOSE) run --rm \
		-v $(SCRIPT):/script.sh $(SERVICE) \
		bash /script.sh

.PHONY: stop
stop:
	-$(DOCKER_COMPOSE) stop $(SERVICE)

.PHONY: clean
clean: SYSTEM=0
clean:
	$(DOCKER) rm -f $(SERVICE) $(SERVICE_URL) &> /dev/null ||  true
	$(DOCKER) volume rm $$(docker volume ls -qf dangling=true) &> /dev/null || true
	[[ $(SYSTEM) == 1 ]] && $(DOCKER) system prune -f || true

.PHONY: release
# XXX: For use in CI server
release:
	@echo "Using SERVICE_URL: $(SERVICE_URL)"
	@echo "Using BUILD_VERSION: $(BUILD_VERSION)"

	$(DOCKER) push $(SERVICE_URL):$(BUILD_VERSION)
	$(DOCKER) push $(SERVICE_URL):$(VERSION_PUSH)