.PHONY: build
build:
	@echo Building environment...
	@./scripts/proxy docker build \
		--build-arg UID=$$(id -u) --build-arg GID=$$(id -g) \
		-q -t gitlab-v2 dockerfiles/
