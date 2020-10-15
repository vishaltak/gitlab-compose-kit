COMPOSE_FILES += -f docker-compose.common.yml
COMPOSE_FILES += -f docker-compose.services.yml
ifneq (,$(wildcard docker-compose.override.yml))
COMPOSE_FILES += -f docker-compose.override.yml
endif

AUX_COMPOSE_FILES += -f docker-compose.aux.yml
ifneq (,$(wildcard docker-compose.aux.override.yml))
AUX_COMPOSE_FILES += -f docker-compose.aux.override.yml
endif

DOCKER_COMPOSE := ./scripts/proxy docker-compose $(COMPOSE_FILES)
DOCKER_COMPOSE_AUX := $(DOCKER_COMPOSE) $(AUX_COMPOSE_FILES)

.PHONY: dc-config
dc-config:
	$(DOCKER_COMPOSE) config

.PHONY: dc-config-aux
dc-config-aux:
	$(DOCKER_COMPOSE_AUX) config
