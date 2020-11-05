.PHONY: build
build:
	@echo Building environment...
	@$(DOCKER_COMPOSE) build

.PHONY: rebuild
rebuild:
	@echo Re-building environment...
	@$(DOCKER_COMPOSE) build --no-cache spring

.PHONY: push
push: build
	@echo Checking version...
	@git describe
	@$(DOCKER_COMPOSE) push
