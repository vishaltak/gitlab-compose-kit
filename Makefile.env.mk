.PHONY: create-dev
create-dev: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=development \
		spring /scripts/entrypoint/gitlab-rails-exec.sh /scripts/helpers/create-dev-env.sh

.PHONY: create-test
create-test: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=test \
		spring /scripts/entrypoint/gitlab-rails-exec.sh bash -c 'bin/rake -t db:drop db:prepare'

.PHONY: create-runner
create-runner: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=development -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bin/rails runner "Ci::Runner.create(runner_type: :instance_type, token: 'SHARED_RUNNER_TOKEN')"

.PHONY: create
create: create-dev create-test create-runner

.PHONY: migrate-dev
migrate-dev:
	./scripts/proxy docker-compose run -e RAILS_ENV=development -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bash -c 'bin/rake db:migrate'

.PHONY: migrate-test
migrate-test:
	./scripts/proxy docker-compose run -e RAILS_ENV=test -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bash -c 'bin/rake db:migrate'

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
	./scripts/proxy docker-compose run -e RAILS_ENV=test -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bash -c 'bin/rake gitlab:assets:compile'

.PHONY: webpack-compile
webpack-compile:
	./scripts/proxy docker-compose run -e FORCE_WEBPACK_COMPILE=true webpack

.PHONY: env
env:
	./scripts/proxy bash
