COMPOSE_FILES += -f docker-compose.common.yml
COMPOSE_FILES += -f docker-compose.services.yml
ifneq (,$(wildcard docker-compose.override.yml))
COMPOSE_FILES += -f docker-compose.override.yml
endif

AUX_COMPOSE_FILES += -f docker-compose.aux.yml
ifneq (,$(wildcard docker-compose.aux.override.yml))
AUX_COMPOSE_FILES += -f docker-compose.aux.override.yml
endif

DOCKER_COMPOSE := ./scripts/env docker-compose $(COMPOSE_FILES)
DOCKER_COMPOSE_AUX := $(DOCKER_COMPOSE) $(AUX_COMPOSE_FILES)

.PHONY: dc-config
dc-config:
	$(DOCKER_COMPOSE) config

.PHONY: dc-config-aux
dc-config-aux:
	$(DOCKER_COMPOSE_AUX) config

.PHONY: dc-pull
dc-pull: COMPOSE_PULL_IMAGE_SERVICES=redis minio jaeger prometheus registry dind node-exporter cadvisor runner
dc-pull:
	$(DOCKER_COMPOSE_AUX) pull --ignore-pull-failures $(COMPOSE_PULL_IMAGE_SERVICES)
