## GitLab Development using Docker Compose

This projects aims to ease GitLab Development,
by enabling the use of minimal containers / micro-services
with minimal set of dependencies.

It does not use any of existing [GitLab Development Kit](https://gitlab.com/gitlab-org/gitlab-development-kit/) sources.

### Features

It currently supports:

- GitLab Rails: Unicorn / Sidekiq,
- GitLab Workhorse,
- Gitaly,
- PostgreSQL,
- Redis,
- SSH,
- GitLab Pages,
- GitLab Runner,
- Minio as Object Storage backend,
- Rails 5,
- Jaeger,
- Runs on Puma,
- Prometheus with cAdvisor (to gather container metrics)

It allows to:

- Run development environment,
- Run tests,
- Easily teardown and start a new environment,
- Run remote environment over SSH,
- Run tests live in Chrome on Linux,
- Use single Compose Kit for both CE and EE development,
- Simulate the Object Storage usage.

How it differs from GitLab Development Kit it uses containers for everything,
starting from scratch, building minimal container per application.
Everything has it's own container:

- GitLab Unicorn,
- GitLab Sidekiq,
- GitLab Workhorse,
- Gitaly,
- PostgreSQL,
- Redis,
- Webpacks,
- OpenSSH,
- Container Registry,
- GitLab Pages,
- GitLab Runner,
- Nested Docker Engine (for running CI jobs),
- Minio (for Object Storage)

For **remote mode** at least 4GB of RAM is required, but this is BARE minimum,
with **ZRAM compression configured**.

The containers interact via HTTP/TCP using intra-container networking.
There's also a shared volume `/home/git` between: Unicorn, Sidekiq, Workhorse, Gitaly and OpenSSH.

It still doesn't support:

- Geo
- Does not start Grafana,
- and others...

### Requirements

1. Docker Engine,
2. Docker Compose,
3. GNU Make,
4. Linux machine (it might work on Docker for Mac, but not guaranteed).

### Use it

#### 1. Clone

First clone this repository:

```bash
git clone https://gitlab.com/gitlab-org/gitlab-compose-kit.git
```

#### 1.1. Configure NFS (for macOS)

On macOS this project uses NFS to pass data between host and containers.
It seems to be more performant than using [osxfs](https://docs.docker.com/docker-for-mac/osxfs-caching/#performance-implications-of-host-container-file-system-consistency).

To configure an NFS server on macOS, run this simple script that
sets `/etc/exports`:

```bash
sudo scripts/setup-mac-exports
-- Setting /etc/exports...
-- Restarting nfsd...
-- Done.
```

#### 1.2. Use `bind-mount` on macOS

By default this project uses NFS to pass data between host and containers on macOS.

You can force it to use bind-mount with `FORCE_BIND_MOUNT=1`
(which is significantly slower than NFS on Mac)
added to `gck.env`:

```bash
export FORCE_BIND_MOUNT=1
```

#### 1.3 Install requirements

Debian/Ubuntu:

```bash
# requirements install
sudo apt install docker.io docker-compose make
# add current user to docker group
sudo usermod -aG docker $USER
```

The current user will need to log out and back in to have the usermod take effect.

#### 2. Run to setup

```bash
$ make create
```

This will take long minutes to build base docker image, compile all dependencies,
provision application.

#### 3. Start the development environment (and keep it running in shell)

```bash
$ make up
```

This will run application in background.

To run it interactively:

```bash
$ make run
```

Then, to reload environment simply Ctrl-C and re-run it again :)

1. **Access GitLab: http://localhost:3000/**
2. **Access Minio: http://localhost:9000/** (TEST_KEY / TEST_SECRET)
3. **Access SSH: ssh://localhost:2222/**
4. **Access Registry: http://localhost:5000/v2/_ping**

#### 4. Update

```bash
make update
```

This command will:

1. Pull and merge all sources into current branch,
2. Migrate development and test database.

#### 4.1. Switch to latest master

Sometimes you might want to update all dependencies
and switch to latest versions of everything on master.

```bash
make latest-master
```

#### 5. Drop into the shell (for tests)

```bash
$ make shell
$ bin/rspec spec/...
```

### 6. Stop environment

```bash
$ make down
```

This will shutdown all containers, releasing all resources.

### 7. Destroy

```bash
$ make destroy
```

Afterwards you have to run `make create` again :)

## Development

After running `make create` every folder `gitaly`, `gitlab-rails` etc will contain a .git file with the remote location of the project.

You can view these by `cd` into one of the directories and type `git remote -v`.

Once you have finished developing you can use easily use this to deploy it back to the correct remote project.

## User GitLab config

You sometimes want to configure additional configs.

GCK manages all configs on behalf of you, so you should
never manually edit them.

Only these configs are supported today:

- `gitlab.yml`: is merged into `gitlab-rails/config/gitlab.yml`
- `database.yml`: is merged into `gitlab-rails/config/database.yml`
- `resque.yml`: is merged into `gitlab-rails/config/resque.yml`
- `cable.yml`: is merged into `gitlab-rails/config/cable.yml`

To use it edit `./gck.yml` after the setup,
adding the entries that you need to extend:

```yaml
gitlab.yml: # merge with `gitlab-rails/config/gitlab.yml`
  development:
    omniauth:
      providers:
        - { name: 'google_oauth2',
            app_id: 'my-app-id.apps.googleusercontent.com',
            app_secret: 'my-secret',
            args: { access_type: 'offline', approval_prompt: '' } }

database.yml: # merge with `gitlab-rails/config/database.yml`
  development:
    load_balancing:
      hosts:
        - postgres
        - postgres
```

The above configures the following items:

1. We inject `Omniauth` provider to enable integration with Google services,
   this for example allows you to create Kubernetes clusters,
2. We inject `load_balancing` configuration which allows to simulate application
   behaviour with load balancing enabled.

Then run GCK again with `make web`, `make up` or similar command.

## Pages

To access GitLab Pages you have to use HTTP proxy.
The Pages proxy runs on `http://localhost:8989`.

## Performance

It works great on Linux where the data can be natively shared between filesystems.
However, it is not so great when using Docker for Mac due to poor filesystem performance.
Read more about [osxfs-caching](https://docs.docker.com/docker-for-mac/osxfs-caching/#performance-implications-of-host-container-file-system-consistency).

This project tries to store as much as possible on Docker VM.
The source code is still shared, thus it achieves suboptimal
performance due to significant overhead.

On macOS this project uses NFS instead of `osxfs`. This gives much better performance,
but needs a little more work to setup initially.

Running natively will always achieve better performance, as there's simply no virtualization overhead.
This is not a case for Linux, as running in container allows to achieve 99.99% of the host performance.

## GitLab CE and GitLab EE interwork

GitLab Compose Kit uses the single shared development database, but separate GitLab and GitLab FOSS databases for testing. The testing database is automatically deduced from running code or used `FOSS_ONLY` environment variable.

By setting the `FOSS_ONLY` to `1` you will force to run GitLab CE only.

This also means that if you only so far worked on GitLab EE, after switching branch you might want to create CE database and run all components as CE:

```bash
make create-test FOSS_ONLY=1
make web FOSS_ONLY=1
make shell FOSS_ONLY=1
make migrate-test FOSS_ONLY=1
```

## GitLab and GitLab FOSS interwork

There's also a `master-foss` branch available which is being tracked to `origin-foss/master`.
You can easily pick any FOSS branch with regular git commands, create new branches and push to FOSS:

```bash
git checkout master-foss
git checkout -b my-feature-foss
git push -u origin-foss my-feature-foss
```

This also means that if you only so far worked on GitLab, after switching branch you might want to create FOSS database:

```bash
make create-test
```

It also often happens that you want to migrate database, use any of these commands:

```bash
make migrate
make migrate-test
make migrate-dev
```

## X11 and Chrome for testing

When running on Linux GitLab Compose Kit shares `.X11-unix` with container and makes to run Chrome in non-headless mode. You will see all tests being executed live, in Chrome.

You can disable it with (can be put in `gck.env`):

```ruby
export CHROME_HEADLESS=true
```

## Use Rails server (thin) web-server

Sometimes it is desired to use Thin web server (one that comes with Rails). Before running any command just use:

```ruby
export USE_WEB_SERVER=thin
```

## Use Unicorn web-server (not longer default)

```ruby
export USE_WEB_SERVER=unicorn
```

Configure number of workers (default: 2 workers):

```bash
export CUSTOM_WEB_CONFIG=3 # 3 workers
export CUSTOM_WEB_CONFIG=1 # 1 worker
```

## Use PUMA web-server (default)

```ruby
export USE_WEB_SERVER=puma
```

Configure number of workers and threads (default: 2 workers, 4 threads):

```bash
export CUSTOM_WEB_CONFIG=3:6 # 3 workers, 6 threads
export CUSTOM_WEB_CONFIG=1:3 # 1 worker, 3 threads
```

## Use OpenTracing

GitLab Compose Kit supports Jaeger integration that allows to see a correlation
of all events as part of [Tracing](https://docs.gitlab.com/ee/user/project/operations/tracing.html).

To use Tracing, you have to enable it for a moment, or forever:

```bash
# forever, by adding to gck.env
export USE_TRACING=jaeger >> gck.env

# for a moment
make web USE_TRACING=jaeger
```

Open [Performance Bar](https://docs.gitlab.com/ee/administration/monitoring/performance/performance_bar.html) or open Jaeger UI: https://localhost:16686.

## Use Prometheus

GitLab Compose Kit can run Prometheus that will scrape all metrics from all started components:
Puma, Unicorn, Sidekiq, Workhorse and Gitaly, except Runner.

To use Prometheus integration, you need to get a token first from GitLab:

1. Start GitLab,
2. Go to http://localhost:3000/admin/health_check (or any other relevant URL),
3. Get `METRICS_TOKEN` and write it to `gck.env`: `export METRICS_TOKEN=3i113EJN5zf4Ng7Nm-mg >> gck.env`,
4. Run Prometheus `make prometheus`.

The Prometheus will be accessible on http://localhost:9090/  (or any other custom URL).

## Drop cache

Sometimes it is useful to reinstall all gems, node modules and so-on without recreating databases, just use:

```bash
make drop-cache
```

## Remote environment

This project can use `lsyncd` to run remote environment.

To configure the use of remote environment create a file `gck.env`:

```bash
export SSH_TARGET_DIR=gitlab-compose-kit
export SSH_TARGET_USER=gitlab
export SSH_TARGET_HOST=my-remote-server
export SSH_TARGET_PORT=22 # default: 22
```

On remote environment you have to run as unprivileged user.
It can be any user `gitlab`, `ubuntu` as long as it is not `root`.

## Running `production`-like

It is possible to run application in `production`-like environment.

The `RAILS_ENV=production` uses the same database, and configs,
but runs application with application caching enabled.

To selectively run for example `web` or `sidekiq`:

```bash
make web RAILS_ENV=production
make sidekiq RAILS_ENV=production
```

## Using [rbtrace](https://github.com/tmm1/rbtrace)

[rbtrace](https://github.com/tmm1/rbtrace) is useful application to attach
and execute Ruby code in currently running processes.

All components of GitLab Compose Kit run with [`ENABLE_RBTRACE=1`](https://docs.gitlab.com/ee/administration/troubleshooting/debug.html#rbtrace).

If you want to connect for example to `Unicorn` and execute some command in that process:

```bash
# find a name of `unicorn_1` process, like `gitlab-v2_unicorn_1`
$ docker ps -a
$ docker exec -it gitlab-v2_unicorn_1 /bin/bash

# now in Unicorn container:
$ ps auxf | pgrep unicorn # or puma, or sidekiq
$ bundle exec rbtrace -p $(ps auxf | pgrep ruby) -e 'GC.stat'
```

### 1. Prepare a remote machine with `rsync`, `docker` and `docker-compose` installed

Use `Ubuntu Bionic`, as it has most of up-to date packages in default repository.

```bash
apt-get install -y rsync docker.io docker-compose
```

### 2. Add a new account on remote server and copy ssh keys

```bash
useradd -s /bin/bash -m -G docker gitlab
```

Optionally copy your SSH identities:

```bash
cp -rv ~/.ssh ~gitlab/
chown -R  gitlab:gitlab ~gitlab/.ssh
```

#### 2.1. Configure zram (optionally)

If you have small amount of RAM it can help to configure ZRAM (memory compression).

```bash
apt-get install zram-config
systemctl enable zram-config
systemctl start zram-config
```

### 3. Create `gck.env` and fill it with details

```bash
export SSH_TARGET_DIR=gitlab-compose-kit
export SSH_TARGET_USER=gitlab
export SSH_TARGET_HOST=my-remote-server
export SSH_TARGET_PORT=22 # default: 22
```

### 4. Prepare and install `lsyncd` on local machine

```bash
# Debian/Ubuntu
apt-get install -y lsyncd

# Mac
brew install lsyncd
```

### 5. Ryn sync process

```bash
make sync
```

### 6. Wait for the initial sync to finish

```
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitlab-pages/" finished: 0
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitlab-workhorse/" finished: 0
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitlab-shell/" finished: 0
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/" finished: 0
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitaly/" finished: 0
22:58:52 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitlab-runner/" finished: 0
22:58:53 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/gitlab-rails/" finished: 0
22:58:54 Normal: Startup of "/home/ayufan/Sources/gitlab-v2/data/" finished: 0
```

### 7. Setup and develop

You can now use regular commands (locally) to develop everything remotely:

```bash
make create
```

## Custom hostname

If you want GitLab to be accessible over custom DNS name, for example in remote mode,
or local mode, when the DNS is already configured you can use:

```bash
export CUSTOM_HOSTNAME=my-custom-dns-name
```

You can set it dynamically, or put that into `gck.env` file.

For **remote mode** this by default fallbacks to `$SSH_TARGET_HOST` which is your likely
the hostname you gonna use.

## Webpack

Webpack by default runs in `single` mode. That means that it precompiles all assets once
and exits. This configuration is ideal for working on application, but is bad if you modify
any of the Frontend code.

You can enable `dev` mode and support reloading of webpack with configuring the `USE_WEBPACK_DEV=true`.
For simplicity you can set that in `gck.env`:

```ruby
export USE_WEBPACK_DEV=true
```

In this mode Webpack is will be run in dev mode when starting webserver.

Since if running in `single` mode you might want to fire assets compilcation,
you can use `webpack-compile` for that purpose:

```ruby
make webpack-compile
```

**Notice:** Use that only when you want to make `gitlab-compose-kit`
to use less resources as `webpack` is very CPU and memory hungry.

## Running `docker-compose` yourself

Sometimes you might want to use `docker-compose`. Currently,
you cannot as `Makefile` defines a number of environment variables,
that are used to configure `docker-compose.yml`.

To use `docker-compose` natively, you have to drop into shell with `make env`.
`make env` gonna configure all `docker-compose.yml` needed variables
and give you an interactive terminal.

```bash
$ make env
$ docker-compose ps
```

## Multiple installations

GitLab Compose Kit can be configured to allow running multiple installations.

You have to do the followings:

1. Clone `gitlab-compose-kit` into another directory,
1. Configure additional set of ports for `ssh`, `web` and `registry`,

Let's assume that you have another `gitlab-compose-kit` stored in directory `gck-reviews`.
You create an `gck.env` file that redefined ports:

```bash
export CUSTOM_WEB_PORT=4000
export CUSTOM_SSH_PORT=4022
export CUSTOM_REGISTRY_PORT=4050
```

The next time you run `make up` on `gck-reviews`, it will provision additional set of containers
for that project, with services exposed on above ports.

## Listing all available ports

Sometimes when you start service it might be hard to discover exactly what
is running, and understanding what address to use in order to connect.

For that purpose use `make ports`. It will look at all ports mapped
on a host and print that in a user readable form:

```bash
$ make ports
./scripts/proxy ./scripts/ports

Available mappings:

ssh://git@my.host:2222 (from gitlab-v2_sshd_1)
http://my.host:3000 (from gitlab-v2_workhorse_1)
```

## Deprecation of `.env`

Due to conflict with `docker-compose`, `GCK` does not allow
to use `.env`. You need to migrate `.env` to `gck.env`,
and each environment variable needs to be prefixed
with `export`:

```bash
export METRICS_TOKEN=3i113EJN5zf4Ng7Nm-mg
```

## Author

Kamil Trzciński, 2017, GitLab

## License

MIT
