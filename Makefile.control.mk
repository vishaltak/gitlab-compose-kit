.PHONY: up
up: deps
	$(DOCKER_COMPOSE) up -d

up-%:
	$(DOCKER_COMPOSE) up -d $*

.PHONY: run
run: deps
	$(DOCKER_COMPOSE) up

.PHONY: db
db: deps
	$(DOCKER_COMPOSE) up postgres redis

.PHONY: web
web: deps
	$(DOCKER_COMPOSE) up workhorse web cable sshd webpack $(USE_TRACING)

.PHONY: web-and-sidekiq
web-and-sidekiq: deps
	$(DOCKER_COMPOSE) up workhorse web cable sidekiq sshd webpack $(USE_TRACING)

cable: deps
	$(DOCKER_COMPOSE) up workhorse cable $(USE_TRACING)

.PHONY: scale
scale: deps
	$(DOCKER_COMPOSE) scale $(SCALE)

.PHONY: sshd
sshd: deps
	$(DOCKER_COMPOSE) up sshd $(USE_TRACING)

.PHONY: sidekiq
sidekiq: deps
	$(DOCKER_COMPOSE) up sidekiq $(USE_TRACING)

.PHONY: runner
runner: deps
	$(DOCKER_COMPOSE) up runner

.PHONY: registry
registry: deps
	$(DOCKER_COMPOSE) up registry

.PHONY: prometheus
prometheus: deps
	$(DOCKER_COMPOSE) up prometheus

.PHONY: restart
restart: deps
	$(DOCKER_COMPOSE_AUX) restart

.PHONY: down
down:
	make kill
	make clean

down-%:
	$(DOCKER_COMPOSE_AUX) rm -fs $*

.PHONY: kill
kill:
	$(DOCKER_COMPOSE_AUX) kill

.PHONY: clean
clean:
	$(DOCKER_COMPOSE_AUX) rm

.PHONY: drop-cache
drop-cache:
	$(DOCKER_COMPOSE) run --no-deps --rm --entrypoint="/bin/bash -c" spring "rm -rf /data/cache/*"
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm

.PHONY: destroy
destroy:
	$(DOCKER_COMPOSE_AUX) down -v --remove-orphans

.PHONY: logs
logs:
	$(DOCKER_COMPOSE_AUX) logs

.PHONY: tail
tail:
	$(DOCKER_COMPOSE_AUX) logs -f

.PHONY: ps
ps:
	$(DOCKER_COMPOSE_AUX) ps

.PHONY: pgadmin
pgadmin:
	$(DOCKER_COMPOSE_AUX) up -d pgadmin

.PHONY: spring
spring: deps
	$(DOCKER_COMPOSE) up -d spring

.PHONY: shell
shell: spring
	$(DOCKER_COMPOSE) exec spring /scripts/entrypoint/gitlab-rails-exec.sh /bin/bash

.PHONY: command
command: spring
	$(DOCKER_COMPOSE) exec -T spring /scripts/entrypoint/gitlab-rails-exec.sh $(COMMAND)

.PHONY: console
console: spring
	$(DOCKER_COMPOSE) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails console

.PHONY: dbconsole
dbconsole: spring
	$(DOCKER_COMPOSE) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p

.PHONY: dbconsole-test
dbconsole-test: spring
	$(DOCKER_COMPOSE) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p -e test

.PHONY: redisconsole
redisconsole: spring
	$(DOCKER_COMPOSE) exec spring /scripts/entrypoint/gitlab-rails-exec.sh redis-cli -h redis
