.PHONY: up
up: deps
	./scripts/proxy docker-compose up -d

.PHONY: run
run: deps
	./scripts/proxy docker-compose up

.PHONY: db
db: deps
	./scripts/proxy docker-compose up $(USE_DB) redis

.PHONY: web
web: deps
	./scripts/proxy docker-compose up workhorse $(USE_WEB_SERVER) sshd webpack $(USE_TRACING)

.PHONY: web-and-sidekiq
web-and-sidekiq: deps
	./scripts/proxy docker-compose up workhorse $(USE_WEB_SERVER) sidekiq sshd webpack $(USE_TRACING)

.PHONY: scale
scale: deps
	./scripts/proxy docker-compose scale $(SCALE)

.PHONY: sshd
sshd: deps
	./scripts/proxy docker-compose up sshd $(USE_TRACING)

.PHONY: sidekiq
sidekiq: deps
	./scripts/proxy docker-compose up sidekiq $(USE_TRACING)

.PHONY: runner
runner: deps
	./scripts/proxy docker-compose up runner

.PHONY: registry
registry: deps
	./scripts/proxy docker-compose up registry

.PHONY: prometheus
prometheus: deps
	./scripts/proxy docker-compose up prometheus

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

.PHONY: drop-cache
drop-cache:
	./scripts/proxy docker-compose run --no-deps --rm --entrypoint="/bin/bash -c" spring "rm -rf /data/cache/*"
	./scripts/proxy docker-compose kill
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

.PHONY: ps
ps:
	docker-compose ps

.PHONY: spring
spring: deps
	./scripts/proxy docker-compose up -d spring

.PHONY: shell
shell: spring
	./scripts/proxy docker-compose exec spring /scripts/entrypoint/gitlab-rails-exec.sh /bin/bash

.PHONY: console
console: spring
	./scripts/proxy docker-compose exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails console

.PHONY: dbconsole
dbconsole: spring
	./scripts/proxy docker-compose exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p

.PHONY: dbconsole-test
dbconsole-test: spring
	./scripts/proxy docker-compose exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p -e test

.PHONY: redisconsole
redisconsole: spring
	./scripts/proxy docker-compose exec spring /scripts/entrypoint/gitlab-rails-exec.sh redis-cli -h redis
