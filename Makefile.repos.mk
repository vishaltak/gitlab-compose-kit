data:
	mkdir -p data

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

.PHONY: repos
repos: gitaly gitlab-shell gitlab-pages gitlab-rails gitlab-workhorse data

.PHONY: deps
deps: repos

.PHONY: update-repos
update-repos: repos
	git -C gitaly pull
	git -C gitlab-rails pull
	git -C gitlab-shell pull
	git -C gitlab-workhorse pull
