data:
	mkdir -p data

gitaly/.git:
	git clone https://gitlab.com/gitlab-org/gitaly.git
	git -C gitaly remote set-url origin --push git@gitlab.com:gitlab-org/gitaly.git

gitlab-shell/.git:
	git clone https://gitlab.com/gitlab-org/gitlab-shell.git
	git -C gitlab-shell remote set-url origin --push git@gitlab.com:gitlab-org/gitlab-shell.git

gitlab-pages/.git:
	git clone https://gitlab.com/gitlab-org/gitlab-pages.git
	git -C gitlab-pages remote set-url origin --push git@gitlab.com:gitlab-org/gitlab-pages.git

gitlab-rails/.git:
	git clone https://gitlab.com/gitlab-org/gitlab.git gitlab-rails
	git -C gitlab-rails remote add origin-foss https://gitlab.com/gitlab-org/gitlab-foss.git
	git -C gitlab-rails remote set-url origin --push git@gitlab.com:gitlab-org/gitlab.git
	git -C gitlab-rails remote set-url origin-foss --push git@gitlab.com:gitlab-org/gitlab-foss.git
	git -C gitlab-rails fetch origin-foss
	git -C gitlab-rails branch --track master-foss origin-foss/master

gitlab-workhorse/.git:
	git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git
	git -C gitlab-workhorse remote set-url origin --push git@gitlab.com:gitlab-org/gitlab-workhorse.git

.PHONY: repos
repos: gitaly/.git gitlab-shell/.git gitlab-pages/.git gitlab-rails/.git gitlab-workhorse/.git data

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
	git -C gitlab-rails checkout master-ee
	git -C gitlab-rails pull
	git -C gitlab-rails checkout master
	git -C gitlab-rails pull
	git -C gitlab-shell checkout master
	git -C gitlab-shell pull
	git -C gitlab-workhorse checkout master
	git -C gitlab-workhorse pull
	make down
