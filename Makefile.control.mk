.PHONY: up
up: deps
	docker-compose up

.PHONY: down
down:
	docker-compose kill
	docker-compose rm --remove-orphans

.PHONY: destroy
destroy:
	docker-compose down -v --remove-orphans

.PHONY: background
background: deps
	docker-compose up -d

.PHONY: logs
logs: deps
	docker-compose logs

.PHONY: shell
shell: deps
	docker-compose run sidekiq /bin/bash

.PHONY: console
console: deps
	docker-compose run sidekiq bundle exec rails console
