all: help

help:
	@echo 'Available targets:'
	@sed -n 's/^.PHONY: \(.*\)$$/- \1/p' Makefile

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

.PHONY: setup-dev
setup-dev: deps
	docker-compose run -e RAILS_ENV=development sidekiq bash -c 'bin/rake db:create && bin/rake dev:setup'

.PHONY: setup-test
setup-test: deps
	docker-compose run -e RAILS_ENV=test sidekiq bash -c 'bin/rake db:drop; bin/rake db:create && bin/rake db:setup'

.PHONY: setup
setup: setup-dev setup-test

.PHONY: update-repos
update-repos: deps
	git -C gitaly pull
	git -C gitlab-rails pull
	git -C gitlab-shell pull
	git -C gitlab-workhorse pull

.PHONY: update-dev
update-dev: update-repos
	docker-compose run -e RAILS_ENV=development sidekiq bash -c 'bin/rake db:migrate'

.PHONY: update-test
update-test: update-repos
	docker-compose run -e RAILS_ENV=test sidekiq bash -c 'bin/rake db:migrate'

.PHONY: update
update: update-dev update-test

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
shell: deps
	docker-compose run sidekiq /bin/bash
