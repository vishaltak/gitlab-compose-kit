.PHONY: build
build:
	@echo Building environment...
	@./scripts/proxy docker-compose build

.PHONY: push
push: build
	@echo Checking version...
	@git describe --exact-match
	docker-compose push
