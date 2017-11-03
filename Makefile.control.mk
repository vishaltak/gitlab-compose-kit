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
	docker-compose up workhorse unicorn sshd webpack

.PHONY: sshd
sshd: deps
	docker-compose up sshd

.PHONY: sidekiq
sidekiq: deps
	docker-compose up sidekiq

.PHONY: restart
restart: deps
	docker-compose restart

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

.PHONY: spring
spring: deps
	docker-compose up -d spring

.PHONY: shell
shell: spring
	docker-compose exec spring /bin/bash

.PHONY: console
console: spring
	docker-compose exec spring bundle exec rails console

.PHONY: webpack-compile
webpack-compile: spring
	docker-compose exec spring bin/rake webpack:compile
