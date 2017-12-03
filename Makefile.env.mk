.PHONY: create-dev
create-dev: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=development -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bash -c 'bin/rake db:create && bin/rake dev:setup'

.PHONY: create-test
create-test: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=test -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bash -c 'bin/rake db:drop; bin/rake db:create && bin/rake db:setup'

.PHONY: create-runner
create-runner: deps
	./scripts/proxy docker-compose run -e RAILS_ENV=development -e IN_MEMORY_APPLICATION_SETTINGS=true \
		spring bin/rails runner "Ci::Runner.create(is_shared: true, token: 'SHARED_RUNNER_TOKEN')"

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
