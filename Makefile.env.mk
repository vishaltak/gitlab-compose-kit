.PHONY: create-dev
create-dev: deps
	docker-compose run -e RAILS_ENV=development sidekiq bash -c 'bin/rake db:create && bin/rake dev:setup'

.PHONY: create-test
create-test: deps
	docker-compose run -e RAILS_ENV=test sidekiq bash -c 'bin/rake db:drop; bin/rake db:create && bin/rake db:setup'

.PHONY: create
create: create-dev create-test

.PHONY: update-repos
update-repos: deps
	git -C gitaly pull
	git -C gitlab-rails pull
	git -C gitlab-shell pull
	git -C gitlab-workhorse pull

.PHONY: migrate-dev
migrate-dev:
	docker-compose run -e RAILS_ENV=development sidekiq bash -c 'bin/rake db:migrate'

.PHONY: update-test
migrate-test:
	docker-compose run -e RAILS_ENV=test sidekiq bash -c 'bin/rake db:migrate'

.PHONY: update-dev
update-dev: update-repos
	make migrate-dev

.PHONY: update-test
update-test: update-repos
	make migrate-test

.PHONY: update
update: update-dev update-test
