.PHONY: build
build:
	@echo Building environment...
	@docker build \
		--build-arg USER=$(USER) --build-arg UID=$$(id -u) --build-arg GID=$$(id -g) --build-arg HOME="$(CURDIR)" \
		-q -t gitlab-v2 dockerfiles/

data:
	mkdir -p data

data/gitlab.yml: data
	touch data/gitlab.yml

gitaly:
	git clone https://gitlab.com/gitlab-org/gitaly.git

gitlab-shell:
	git clone https://gitlab.com/gitlab-org/gitlab-shell.git

gitlab-pages:
	git clone https://gitlab.com/gitlab-org/gitlab-pages.git

gitlab-rails:
	git clone https://gitlab.com/gitlab-org/gitlab-ce.git gitlab-rails

gitlab-workhorse:
	git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git

.PHONY: deps
deps: build gitaly gitlab-shell gitlab-pages gitlab-rails gitlab-workhorse data data/gitlab.yml
