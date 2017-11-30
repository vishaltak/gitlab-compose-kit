.PHONY: build
build:
	@echo Building environment...
	@./scripts/proxy docker-compose build
