.PHONY: create-dev
create-dev: deps
	docker-compose run -e RAILS_ENV=development spring bash -c 'bin/rake db:create && bin/rake dev:setup'

.PHONY: create-test
create-test: deps
	docker-compose run -e RAILS_ENV=test spring bash -c 'bin/rake db:drop; bin/rake db:create && bin/rake db:setup'

.PHONY: create-runner
create-runner: deps
	docker-compose run -e RAILS_ENV=development spring bin/rails runner "Ci::Runner.create(is_shared: true, token: 'SHARED_RUNNER_TOKEN')"

.PHONY: create
create: create-dev create-test create-runner

.PHONY: update-repos
update-repos: deps
	git -C gitaly pull
	git -C gitlab-rails pull
	git -C gitlab-shell pull
	git -C gitlab-workhorse pull

.PHONY: migrate-dev
migrate-dev:
	docker-compose run -e RAILS_ENV=development spring bash -c 'bin/rake db:migrate'

.PHONY: migrate-test
migrate-test:
	docker-compose run -e RAILS_ENV=test spring bash -c 'bin/rake db:migrate'

.PHONY: update-dev
update-dev: update-repos
	make migrate-dev

.PHONY: update-test
update-test: update-repos
	make migrate-test

.PHONY: update
update: update-dev update-test
