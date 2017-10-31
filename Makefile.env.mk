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
