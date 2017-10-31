.PHONY: up
up: deps
	docker-compose up

.PHONY: down
down:
	docker-compose down

.PHONY: background
background: deps
	docker-compose up -d

.PHONY: logs
logs: deps
	docker-compose logs

.PHONY: destroy
destroy:
	docker-compose down -v --remove-orphans

.PHONY: shell
shell: deps
	docker-compose run sidekiq /bin/bash

.PHONY: console
console: deps
	docker-compose run sidekiq bundle exec rails console
