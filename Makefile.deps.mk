.PHONY: build
build:
	@echo Building environment...
	@$(DOCKER_COMPOSE) build

.PHONY: push
push: build
	@echo Checking version...
	@git describe
	@$(DOCKER_COMPOSE) push
