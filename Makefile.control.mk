.PHONY: up
up: deps
	docker-compose up -d

.PHONY: run
run: deps
	docker-compose up

.PHONY: down
down:
	docker-compose kill
	docker-compose rm --remove-orphans

.PHONY: destroy
destroy:
	docker-compose down -v --remove-orphans

.PHONY: logs
logs:
	docker-compose logs

.PHONY: tail
tail:
	docker-compose logs -f

.PHONY: shell
shell: deps
	docker-compose run sidekiq /bin/bash

.PHONY: console
console: deps
	docker-compose run sidekiq bundle exec rails console
