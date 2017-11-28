.PHONY: build
build:
	@echo Building environment...
	@./scripts/proxy docker build \
		--build-arg USER=$(USER) --build-arg UID=$$(id -u) --build-arg GID=$$(id -g) --build-arg HOME="$(CURDIR)" \
		-q -t gitlab-v2 dockerfiles/
