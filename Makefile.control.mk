.PHONY: up
up: deps
	docker-compose up -d

.PHONY: run
run: deps
	docker-compose up

.PHONY: db
db: deps
	docker-compose up postgres redis

.PHONY: web
web: deps
	docker-compose up workhorse unicorn sshd

.PHONY: sshd
sshd: deps
	docker-compose up sshd

.PHONY: sidekiq
sidekiq: deps
	docker-compose up sidekiq

.PHONY: down
down:
	docker-compose kill
	docker-compose rm

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
	docker-compose run spring /bin/bash

.PHONY: console
console: deps
	docker-compose run spring bundle exec rails console
