.DEFAULT_GOAL := noop
SHELL := /bin/bash

.PHONY: install
install:
	@if [ -d ${HOME}/.local/bin ] && [ -x ${HOME}/.local/bin/szcdfi.sh ]; then \
		${HOME}/.local/bin/szcdfi.sh; \
	else \
		./bin/szcdfi.sh; \
	fi

.PHONY: enter-test-env
enter-test-env: build-test-env
	docker compose -f .test/docker-compose.yml run szcdf-installer-test /bin/bash

.PHONY: build-test-env
build-test-env:
	docker compose -f .test/docker-compose.yml build

.PHONY: noop
noop:
	@echo "No operation. Choose from the following targets:"
	@echo "  install: Install the szcdf-core system."
	@echo "  enter-test-env: Enter the test environment."
	@echo "  build-test-env: Build the test environment."