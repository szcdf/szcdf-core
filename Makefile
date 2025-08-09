all: enter-test-env

.PHONY: enter-test-env
enter-test-env: build-test-env
	docker compose -f .test/docker-compose.yml run szcdf-installer-test /bin/bash

.PHONY: build-test-env
build-test-env:
	docker compose -f .test/docker-compose.yml build
