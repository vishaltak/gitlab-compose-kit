all: up

.PHONY: build
build:
	@echo Building environment...
	@docker build \
		--build-arg USER=$(USER) --build-arg UID=$$(id -u) --build-arg GID=$$(id -g) --build-arg HOME="$(CURDIR)" \
		-q -t gitlab-v2 dockerfiles/

data:
	mkdir -p data

gitaly:
	git clone https://gitlab.com/gitlab-org/gitaly.git

gitlab-shell:
	git clone https://gitlab.com/gitlab-org/gitlab-shell.git

gitlab-rails:
	git clone https://gitlab.com/gitlab-org/gitlab-ce.git gitlab-rails

gitlab-workhorse:
	git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git

.PHONY: deps
deps: build gitaly gitlab-shell gitlab-rails gitlab-workhorse data

.PHONY: setup
setup: deps
	docker-compose run sidekiq bash -c 'bundle exec rake db:create && bundle exec rake dev:setup'

.PHONY: up
up: deps
	docker-compose up

.PHONY: down
down:
	docker-compose down

.PHONY: destroy
destroy:
	docker-compose down -v --remove-orphans

.PHONY: shell
shell:
	docker-compose run unicorn /bin/bash
