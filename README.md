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
- MySQL,
- Redis,
- SSH,
- GitLab Pages,
- GitLab Runner,
- Minio as Object Storage backend,
- Rails 5

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
- MySQL,
- Redis,
- Webpacks,
- OpenSSH,
- Container Registry,
- GitLab Pages,
- GitLab Runner,
- Nested Docker Engine (for running CI jobs),
- Minio (for Object Storage)

For **remote mode** at least 2GB of RAM, but this is BARE minimum.

The containers interact via HTTP/TCP using intra-container networking.
There's also a shared volume `/home/git` between: Unicorn, Sidekiq, Workhorse, Gitaly and OpenSSH.

It still doesn't support:
- Geo
- and others...

### Requirements

1. Docker Engine,
2. Docker Compose,
3. GNU Make,
4. Linux machine (it might work on Docker for Mac, but not guaranteed).

### How to use it?

#### 1. Clone:

First clone this repository:

```bash
git clone https://gitlab.com/ayufan/gitlab-compose-kit.git
```

#### 2. Run to setup:

```bash
$ make create
```

This will take long minutes to build base docker image, compile all dependencies,
provision application.

#### 3. Start the development environment (and keep it running in shell):

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

Afterwards you have to run `make setup` again :)

## User GitLab config

You sometimes want to configure `gitlab-rails/config/gitlab.yml`.

It is super easy. Just edit `./gitlab.yml` after setup,
adding only entries that you need:

```yaml
development:
  omniauth:
    providers:
      - { name: 'google_oauth2',
          app_id: 'my-app-id.apps.googleusercontent.com',
          app_secret: 'my-secret',
          args: { access_type: 'offline', approval_prompt: '' } }
```

Then restart `make restart`.

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

Running natively will achieve better performance, as there's simply no virtualization overhead.
This is not a case for Linux, as running in container allows to achieve 99.99% of the host performance.

## CE and EE interwork

GitLab Compose Kit uses the single shared development database, but separate CE and EE databases for testing. The testing database is automatically deduced from running code. When switching branch you might want to kill and start again:

```bash
make kill
make shell
```

This also means that if you only so far worked on CE, after switching branch you might want to create EE database:

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

You can disable it with (can be put in `.env`):

```ruby
export CHROME_HEADLESS=true
```

## Use Thin web-server

Sometimes it is desired to use Thin web server (one that comes with Rails). Before running any command just use:

```ruby
export USE_RAILS_SERVER=true
```

## Use Rails5

Testing Rails5 never got easier, just use:

```ruby
export USE_RAILS5=true
```

Or:

```ruby
make console USE_RAILS5=true
make shell USE_RAILS5=true
make web USE_RAILS5=true
make up USE_RAILS5=true
```

## Use MySQL

Testing Rails5 never got easier, just use:

```ruby
export USE_DB=mysql2
```

Or:

```ruby
make console USE_DB=mysql2
make shell USE_DB=mysql2
make web USE_DB=mysql2
make up USE_DB=mysql2
```

## Drop cache

Sometimes it is useful to reinstall all gems, node modules and so-on without recreating databases, just use:

```bash
make drop-cache
```

## Remote environment

This project can use `lsyncd` to run remote environment.

To configure the use of remote environment create a file `.env`:

```bash
export SSH_TARGET_DIR=gitlab-compose-kit
export SSH_TARGET_USER=gitlab
export SSH_TARGET_HOST=my-remote-server
export SSH_TARGET_PORT=22 # default: 22
```

On remote environment you have to run as unprivileged user.
It can be any user `gitlab`, `ubuntu` as long as it is not `root`.

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

### 3. Create `.env` and fill it with details

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

### 6. Wait for inital sync to finish

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

You can set it dynamically, or put that into `.env` file.

For **remote mode** this by default fallbacks to `$SSH_TARGET_HOST` which is your likely
the hostname you gonna use.

## Author

Kamil Trzciński, 2017, GitLab

## License

MIT
