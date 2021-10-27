.PHONY: create-dev
create-dev: deps
	$(DOCKER_COMPOSE) run -e RAILS_ENV=development \
		spring /scripts/entrypoint/gitlab-rails-exec.sh /scripts/helpers/create-dev-env.sh

.PHONY: create-test
create-test: deps
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rake -t db:drop db:prepare

.PHONY: create-runner
create-runner: deps
	$(DOCKER_COMPOSE) run -e RAILS_ENV=development \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails runner "Ci::Runner.create(runner_type: :instance_type, token: 'SHARED_RUNNER_TOKEN')"

.PHONY: create
create: create-dev create-test create-runner

.PHONY: migrate-dev
migrate-dev:
	$(DOCKER_COMPOSE) run -e RAILS_ENV=development \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rake db:migrate

.PHONY: migrate-test
migrate-test:
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rake db:migrate

.PHONY: update-dev
update-dev: update-repos
	make migrate-dev

.PHONY: update-test
update-test: update-repos
	make migrate-test

.PHONY: update
update: update-dev update-test

.PHONY: assets-compile
assets-compile:
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rake gitlab:assets:compile

.PHONY: webpack-compile
webpack-compile: deps
	$(DOCKER_COMPOSE) run -e FORCE_WEBPACK_COMPILE=true webpack

.PHONY: gitaly-compile
gitaly-compile: deps
	$(DOCKER_COMPOSE) run -e FORCE_GITALY_COMPILE=true gitaly

.PHONY: rails-compile
rails-compile: deps
	$(DOCKER_COMPOSE) run -e RAILS_ENV=development \
		spring /scripts/entrypoint/gitlab-rails-exec.sh /bin/true

.PHONY: env
env:
	./scripts/env bash

.PHONY: ports
ports:
	./scripts/env ./scripts/ports

.PHONY: volumes-usage
volumes-usage:
	./scripts/env ./scripts/volumes-usage

.PHONY: recover-postgres-replica
recover-postgres-replica:
	# reset WAL
	$(DOCKER_COMPOSE_AUX) stop postgres
	$(DOCKER_COMPOSE_AUX) run --rm -u postgres postgres bash -c 'pg_resetwal -f "$$PGDATA"'
	# recreate replica
	$(DOCKER_COMPOSE_AUX) rm -v -f -s postgres-replica
	$(DOCKER_COMPOSE_AUX) up -d postgres-replica
