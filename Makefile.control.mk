.PHONY: up
up: deps
	./scripts/proxy docker-compose up -d

.PHONY: run
run: deps
	./scripts/proxy docker-compose up

.PHONY: db
db: deps
	./scripts/proxy docker-compose up postgres redis

.PHONY: web
web: deps
	./scripts/proxy docker-compose up workhorse unicorn sshd webpack

.PHONY: sshd
sshd: deps
	./scripts/proxy docker-compose up sshd

.PHONY: sidekiq
sidekiq: deps
	./scripts/proxy docker-compose up sidekiq

.PHONY: restart
restart: deps
	./scripts/proxy docker-compose restart

.PHONY: down
down:
	make kill
	make clean

.PHONY: kill
kill:
	./scripts/proxy docker-compose kill

.PHONY: clean
clean:
	./scripts/proxy docker-compose rm

.PHONY: destroy
destroy:
	./scripts/proxy docker-compose down -v --remove-orphans

.PHONY: logs
logs:
	./scripts/proxy docker-compose logs

.PHONY: tail
tail:
	./scripts/proxy docker-compose logs -f

.PHONY: spring
spring: deps
	./scripts/proxy docker-compose up -d spring

.PHONY: shell
shell: spring
	./scripts/proxy docker-compose exec spring /bin/bash

.PHONY: console
console: spring
	./scripts/proxy docker-compose exec spring bin/rails console

.PHONY: webpack-compile
webpack-compile: spring
	./scripts/proxy docker-compose exec spring bin/rake webpack:compile

.PHONY: dbconsole
dbconsole: spring
	./scripts/proxy docker-compose exec spring bin/rails dbconsole -p

.PHONY: dbconsole-test
dbconsole-test: spring
	./scripts/proxy docker-compose exec spring bin/rails dbconsole -p -e test
