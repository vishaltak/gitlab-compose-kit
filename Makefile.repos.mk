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
	git -C gitlab-rails remote add origin-ee https://gitlab.com/gitlab-org/gitlab-ee.git
	git -C gitlab-rails fetch origin-ee

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

.PHONY: latest-master
latest-master: repos
	git -C gitaly checkout master
	git -C gitaly pull
	git -C gitlab-rails checkout master
	git -C gitlab-rails pull
	git -C gitlab-shell checkout master
	git -C gitlab-shell pull
	git -C gitlab-workhorse checkout master
	git -C gitlab-workhorse pull
	make down
