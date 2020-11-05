# These commands run targets detached
.PHONY: up
up: deps # we use `DOCKER_COMPOSE` as we do not want to start AUX services
	$(DOCKER_COMPOSE) up -d

.PHONY: up-%
up-%:
	$(DOCKER_COMPOSE_AUX) up -d $*

# These commands run targets interactively (in a shell)
.PHONY: run
run: deps # we use `DOCKER_COMPOSE` as we do not want to start AUX services
	$(DOCKER_COMPOSE) up

.PHONY: db
db: deps
	$(DOCKER_COMPOSE_AUX) up postgres redis

.PHONY: web
web: deps
	$(DOCKER_COMPOSE_AUX) up workhorse web cable sshd webpack $(USE_TRACING)

.PHONY: web-and-sidekiq
web-and-sidekiq: deps
	$(DOCKER_COMPOSE_AUX) up workhorse web cable sidekiq sshd webpack $(USE_TRACING)

.PHONY: cable
cable: deps
	$(DOCKER_COMPOSE_AUX) up workhorse cable $(USE_TRACING)

.PHONY: sshd
sshd: deps
	$(DOCKER_COMPOSE_AUX) up sshd $(USE_TRACING)

.PHONY: sidekiq
sidekiq: deps
	$(DOCKER_COMPOSE_AUX) up sidekiq $(USE_TRACING)

.PHONY: runner
runner: deps
	$(DOCKER_COMPOSE_AUX) up runner

.PHONY: registry
registry: deps
	$(DOCKER_COMPOSE_AUX) up registry

.PHONY: prometheus
prometheus: deps
	$(DOCKER_COMPOSE_AUX) up prometheus

.PHONY: pgadmin
pgadmin:
	$(DOCKER_COMPOSE_AUX) up pgadmin

# These commands do re-use existing `spring` container to provide
# a quick shell access
.PHONY: shell
shell: up-spring
	$(DOCKER_COMPOSE_AUX) exec spring /scripts/entrypoint/gitlab-rails-exec.sh /bin/bash

.PHONY: command
command: up-spring
	$(DOCKER_COMPOSE_AUX) exec -T spring /scripts/entrypoint/gitlab-rails-exec.sh $(COMMAND)

.PHONY: console
console: up-spring
	$(DOCKER_COMPOSE_AUX) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails console

.PHONY: dbconsole
dbconsole: up-spring
	$(DOCKER_COMPOSE_AUX) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p

.PHONY: dbconsole-test
dbconsole-test: up-spring
	$(DOCKER_COMPOSE_AUX) exec spring /scripts/entrypoint/gitlab-rails-exec.sh bin/rails dbconsole -p -e test

.PHONY: redisconsole
redisconsole: up-spring
	$(DOCKER_COMPOSE_AUX) exec spring /scripts/entrypoint/gitlab-rails-exec.sh redis-cli -h redis

# These commands do restart
.PHONY: restart
restart: deps
	$(DOCKER_COMPOSE_AUX) restart

# These commands allow to control container scaling
.PHONY: scale
scale: deps
	$(DOCKER_COMPOSE_AUX) scale $(SCALE)

# These commands do kill and cleanup containers
.PHONY: down
down:
	make kill
	make clean

.PHONY: down-%
down-%:
	$(DOCKER_COMPOSE_AUX) rm -fs $*

.PHONY: kill
kill:
	$(DOCKER_COMPOSE_AUX) kill

.PHONY: clean
clean:
	$(DOCKER_COMPOSE_AUX) rm

# These commands do drop data
.PHONY: drop-cache
drop-cache:
	$(DOCKER_COMPOSE_AUX) run --no-deps --rm --entrypoint="/bin/bash -c" spring "sudo rm -rf /data/cache/*"
	$(DOCKER_COMPOSE_AUX) kill
	$(DOCKER_COMPOSE_AUX) rm

.PHONY: destroy
destroy:
	$(DOCKER_COMPOSE_AUX) down -v --remove-orphans

# These commands are good for debugging
.PHONY: logs
logs:
	$(DOCKER_COMPOSE_AUX) logs

.PHONY: tail
tail:
	$(DOCKER_COMPOSE_AUX) logs -f --tail=100

.PHONY: ps
ps:
	$(DOCKER_COMPOSE_AUX) ps

.PHONY: attach
attach:
	./scripts/proxy bash -c 'ID=$$(docker ps -f "label=com.docker.compose.project=$$(basename "$$PWD")" -f "label=com.docker.compose.service=$(SERVICE)" -q) && docker attach "$${ID:-missing}"'

.PHONY: attach-web
attach-web: SERVICE=web
attach-web: attach

.PHONY: attach-cable
attach-cable: SERVICE=cable
attach-cable: attach

.PHONY: attach-sidekiq
attach-sidekiq: SERVICE=sidekiq
attach-sidekiq: attach
