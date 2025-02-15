**Note:** For most developers working on the GitLab codebase, the recommended path is to use the [GitLab Development Kit](https://gitlab.com/gitlab-org/gitlab-development-kit/). The GDK will offer a more straightforward path because it runs natively on your machine. If you're looking for something requiring the lowest maintainence effort, [consider using the GDK via GitPod](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/howto/gitpod.md). If you're running Linux and want something container-based, GCK is a great option.

The GCK is built with a completely different philosophy than the GDK, and this difference in architecture means the two are wholly incompatible. Since GCK is heavily Docker-based, maintainence of your local dev environment is significantly easier, however, being Docker based also means that it does not run natively on OSX and may pose problems during setup. There are two open issues that would solve some of the pain of running it on macOS, for those interested in contributing:

- https://gitlab.com/gitlab-org/gitlab-compose-kit/-/issues/31
- https://gitlab.com/gitlab-org/gitlab-compose-kit/-/merge_requests/97

---

## GitLab Development using Docker Compose

This projects aims to ease GitLab Development,
by enabling the use of minimal containers / micro-services
with minimal set of dependencies.

It does not use any of existing [GitLab Development Kit](https://gitlab.com/gitlab-org/gitlab-development-kit/) sources.

### Features

It currently supports:

- GitLab Rails: Unicorn / Sidekiq,
- GitLab Workhorse,
- Gitaly with Praefect,
- PostgreSQL with replication,
- Redis,
- SSH,
- GitLab Pages,
- GitLab Runner,
- Minio as Object Storage backend,
- Rails,
- Jaeger,
- Runs on Puma,
- Prometheus with cAdvisor (to gather container metrics)

It allows to:

- Run development environment,
- Run tests,
- Easily teardown and start a new environment,
- Run remote environment over SSH,
- Run tests live in Chrome or Firefox on Linux,
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

1. Docker Engine
2. Docker Compose (at least version `1.25.0`)
3. GNU Make
4. Linux machine (the best served on `Ubuntu Focal (20.04 LTS)` or `Debian Bullseye (11.0)`)
5. This might work on Docker for Mac, but not guaranteed

### Use it

#### 1. Clone

First clone this repository:

```bash
git clone https://gitlab.com/gitlab-org/gitlab-compose-kit.git
```

#### 1.1. Configure NFS (for macOS)

**Note:** If you're using macOS 10.15+, do not clone the project into your `~/Documents`, `~/Downloads`, `~/Desktop` directories. `nfsd` has permission issues with your user folders and will run into `stale NFS file handle` errors when trying to create the Docker containers. For more context, see [these](https://objekt.click/2019/11/docker-the-problem-with-macos-catalina/) [articles](https://blog.docksal.io/nfs-access-issues-on-macos-10-15-catalina-75cd23606913).

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

This will run the application in the background.

It is also possible to choose what to start using the following syntax - this will
start the runner and web containers, along with their dependencies, for example.

```bash
$ make up-web up-runner
```

To run it interactively:

```bash
$ make run
```

Similarly, you can interactively start a subset of the services as follows:

```bash
$ make web runner
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

### Connecting to other docker-compose systems

Over time, GitLab has deployed more and more systems that cooperate with gitlab-rails and that are
developed in separate repositories but are not managed by our development kits. Examples include
[CustomersDot](https://gitlab.com/gitlab-org/customers-gitlab-com) and [AI services](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/).

Running any of these systems in Docker containers using Docker networks means that they cannot see
each other. In order to see each other, some or all of these services must join the same Docker
network.

This can be accomplished as follows:

1. In GCK:
   1. In `docker-compose.override.yml`, define a new shared network:
      ```yaml
      networks:
        shared:
          name: gck-shared
          driver: bridge
      ```
   1. In `docker-compose.override.yml`, for each service that must see or be seen by an external service,
      add it to both the `default` and `shared` networks:
      ```yaml
       # To make gitlab-rails accessible to other systems as `gitlab-workhorse`
       workhorse:
         networks:
           - default
           - shared

       # To let gitlab-rails contact other systems
       web:
         networks:
           - default
           - shared

       # To let sidekiq contact other systems
       sidekiq:
         networks:
           - default
           - shared
      ```
1. For each system that should be linked:
   1. In its respective `docker-compose.yml`, make the shared network visible:
      ```yaml
      networks:
        gck-shared:
          external: true
      ```
   1. For each service to see or been seen by GCK services:
      ```yaml
      service-name:
        networks:
          - default
          - gck-shared
      ```

### Debugging

While working on any of the Ruby GitLab services in GCK (`web`, `cable` and `sidekiq`), you can use `pry` to set breakpoints.
This is somewhat complicated by the fact that you need to go through a Docker container now:

1. Set a breakpoint via `binding.pry` in a Ruby source file.
1. When the breakpoint is hit, run `make attach-<service_name>` to connect your `stdin` to `pry`.
1. Enter `disable-pry` or press `Ctrl+d` when done debugging.

Example:

```
[8:50:30] work/gl-gck::master ✗ make attach-web
[1] pry(main)> whereami

From: /home/git/gitlab/config/initializers/0_license.rb @ line 3 :

    1: # frozen_string_literal: true
    2: binding.pry
 => 3: Gitlab.ee do
    4:   public_key_file = File.read(Rails.root.join(".license_encryption_key.pub"))
    5:   public_key = OpenSSL::PKey::RSA.new(public_key_file)
    6:   Gitlab::License.encryption_key = public_key
    7: rescue
    8:   warn "WARNING: No valid license encryption key provided."
```

To detach, press `Ctrl+p Ctrl+q` in sequence.

**NOTE**: Pressing `Ctrl+c` while attached will send `SIGKILL` to the container and cause it to shut down.

For more information, see `$ docker help attach`.

### Profiling

#### Rails / Sidekiq

See https://docs.gitlab.com/ee/development/performance.html#profiling

#### Workhorse

In GCK, Workhorse runs a `pprof` server by default. You can connect to it via the `go tool pprof` command
as described in https://golang.org/pkg/net/http/pprof/#pkg-overview.

By default, the `pprof` server listens on container port `6060`. If you would like to reach it from
your host machine, you need to also bind that port by adding an override rule in `docker-compose.override.yml`:

```yaml
workhorse:
    ports:
    - 6060:6060
```

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
    main:
      load_balancing:
        hosts:
          - postgres-replica
          - postgres-replica
```

The above configures the following items:

1. We inject `Omniauth` provider to enable integration with Google services,
   this for example allows you to create Kubernetes clusters,
2. We inject `load_balancing` configuration which allows to simulate application
   behaviour with load balancing enabled.

Then run GCK again with `make web`, `make up` or similar command.

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

## X11 and a Web Browser for testing

When running on Linux GitLab Compose Kit shares `.X11-unix` with container and makes to run your web browser in non-headless mode.
You will see all tests being executed live, in your prefered browser.

You can disable it with (can be put in `gck.env`):

```ruby
export WEBDRIVER_HEADLESS=true
```

## Use Firefox for testing instead of Chrome

Sometimes it is desired to use Firefox instead of Chrome. The GCK comes bundled with `firefox-esr` and `geckodriver`.

You can enabled it with in your current terminal session (`make shell`) or can be put in `gck.env`:

```ruby
export WEBDRIVER=firefox
```

## Configuring an instance CI Runner

The Runner is already running by default in GCK but GitLab. In cases where GitLab does not accept credentials of the runner, run the below command to configure GitLab and therefore enable the instance runner run:

```shell
make create-runner
```

## Scaling services

Under some circumstances you may wish to scale an instance, for example, the CI Runner. To do so, create a docker-compose.override.yml and use the `scale: num` syntax for the appropriate service. For example:

```yaml
version: "2.2"

services:
  runner:
    scale: 4
```

This snippet will instruct docker-compose to spawn 4 CI runner containers, which should be handy if you're running a lot of CI jobs.

Note: This will only be a functional or a good idea with services which are functionally idempotent such as the CI Runner, or Puma and Sidekiq workers. Other services will either not benefit from this, or even interfere with standard operation of the GCK.

## Git over SSH

You can push, pull or clone to/from the local server via HTTPS, but for debugging purposes you might
want to use git over SSH instead, which takes a very different path. [This video](https://youtu.be/0kY0HPFn25o) is a good
introduction if you would like to learn more.

For git-over-ssh to work, you must start the `sshd` service, e.g.:

```shell
make up-sshd
```

This will bind to 2222 on localhost and listen for SSH clients. This integration works by running SSH hooks
that launch various `gitlab-shell` commands, which in return perform tasks such as authenticating the
current user, granting or denying authorization, and calling out to `gitaly`.

To ensure this setup works, you must pair up an SSH keypair on your host machine with the keys managed by the server.
The general steps for registering SSH keys are documented
[here](https://docs.gitlab.com/ee/ssh/#add-an-ssh-key-to-your-gitlab-account).

You can test this connection by running `ssh -Tv -p 2222 git@localhost`, which should output `Welcome to GitLab, @root!`.

You should then be able to clone any repository you own from the local GitLab instance as usual.

## Drop cache

Sometimes it is useful to reinstall all gems, node modules and so-on without recreating databases, just use:

```bash
make drop-cache
```

## Running `production`-like

It is possible to run application in `production`-like environment.

The `RAILS_ENV=production` uses the same database, and configs,
but runs application with application caching disabled.

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
$ docker exec -it gitlab-v2_unicorn_1 bash

# now in Unicorn container:
$ ps auxf | pgrep unicorn # or puma, or sidekiq
$ bundle exec rbtrace -p $(ps auxf | pgrep ruby) -e 'GC.stat'
```

### 1. Prepare a remote machine with `rsync`, `docker` and `docker-compose` installed

Use `Ubuntu Focal (20.04 LTS)` or `Debian Bullseye (11.0)`, as it has most of up-to date packages in default repository.

```bash
apt-get install -y docker.io docker-compose
```

### 2. Add a new account on remote server and copy ssh keys

```bash
useradd -s $(which bash) -m -G docker gitlab
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

### 3. Setup and develop

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

## Service specific setup

### Web server setup

Sometimes it is desirable to use a different web server (the default is Puma).
Set the desired web server in `gck.env`:

```ruby
USE_WEB_SERVER=thin
```

Accepted values are `thin` or `puma` (default).

For servers that support concurrency such as Puma, you can
configure the number of workers and threads (default: 2 workers, 4 threads):

```bash
export CUSTOM_WEB_CONFIG=3:6 # 3 workers, 6 threads
export CUSTOM_WEB_CONFIG=1:3 # 1 worker, 3 threads
```

### ActionCable standalone mode

By default, ActionCable runs on the same Rails web server. To disable:

```ruby
export USE_CABLE_SERVER=false
```

### Webpack

Webpack by default runs in `single` mode. That means that it precompiles all assets once
and exits. This configuration is ideal for working on application, but is bad if you modify
any of the Frontend code.

You can enable `dev` mode and support reloading of webpack with configuring the `USE_WEBPACK_DEV=true`.
For simplicity you can set that in `gck.env`:

```ruby
export USE_WEBPACK_DEV=true
```

In this mode Webpack will be run in dev mode when starting webserver.

**Important:** After enabling Webpack `dev` mode, delete the `gitlab-rails/public/assets`
directory (if it exists). If this directory exists, Rails bypasses Webpack and serves
frontend assets directly from this directory, causing changes to frontend files not
to take effect.

To change the port the dev server listens on:

```ruby
export WEBPACK_CUSTOM_PORT=3808
```

Reminder: If you use are running the GCK on a remote machine with a firewall,
make sure you allow incoming traffic to the appropriate ports.

Since if running in `single` mode you might want to fire assets compilation,
you can use `webpack-compile` for that purpose:

```ruby
make webpack-compile
```

**Notice:** Use that only when you want to make `gitlab-compose-kit`
to use less resources as `webpack` is very CPU and memory hungry.

### Redis

By default, a single Redis container is started (called `redis`). In order to test
data sharding where the application writes and reads data from multiple Redis nodes,
an additional container, `redis-alt` can be started:

```shell
$ make up-redis-alt
```

To specify which Redis client will use this instance, define the store name in `gck.env`:

```
CUSTOM_REDIS_ALT_STORE=cache
```

The `web` container must be restarted when changing this setting.

This will make the Rails application send all cache related operations to `redis-alt`.

You can shell into this instance via:

```shell
$ make redis-alt-console
```

### Gitaly

By adding `ENABLE_PRAEFECT=1` to `gck.env` the additional 3 Gitalies with Praefect will be
run under `praefect` host.

Then go to `Admin Area > Settings > Repository > Repository storage`
to make `praefect` to receive new repositories.

### Pages

To access GitLab Pages you have to use HTTP proxy.
The Pages proxy runs on `http://localhost:8989`.

### PostgreSQL with streaming/physical replication

The usage of load balancing is disabled by default.
To enable it, the usage of load balancing hosts needs
to be configured `gck.yml`:

```yaml
database.yml:
  development:
    main:
      load_balancing:
        hosts:
        - postgres-replica
        - postgres-replica
```

#### Useful commands

- `make dbconsole`: access a shell of DB primary (development DB)
- `make dbconsole-test`: access a shell of DB primary (test DB)
- `make dbconsole-replica`: access a shell of DB replica (development DB)
- `make recover-postgres-replica`: reset and recover replication

#### Testing replication

These commands can help testing replication status:

```ruby
$ make console
> ActiveRecord::Base.connection.load_balancer.primary_write_location
=> "4/73000148"
> ActiveRecord::Base.connection.load_balancer.host.database_replica_location
=> "4/73000148"
```

Additionally this can be tested using `dbconsole`:

```shell
$ make dbconsole
SELECT pg_current_wal_insert_lsn()::text AS location;

$ make dbconsole-replica
SELECT pg_last_wal_replay_lsn()::text AS location;
```

#### Recovery replication

In some cases the DB replica can end-up in a recovery mode (a case of old or lost WAL).
This does requires reseting replication status with:

```shell
make recover-postgres-replica
```

#### Override replication lag setting

A default 1s might not be desired. This setting can be overwritten with
`docker-compose.override.yml`:

```yaml
version: '2.1'

services:
  postgres-replica:
    environment:
    - POSTGRES_REPLICATION_LAG=5000 # change to 5s
```

### Non-essential services

For non-essential services and how to configure and run them, please refer to [README.aux.md](README.aux.md).

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
./scripts/env ./scripts/ports

Available mappings:

ssh://git@my.host:2222 (from gitlab-v2_sshd_1)
http://my.host:3000 (from gitlab-v2_workhorse_1)
```

## Install additional deps

You might regularly want to have additional packages installed
except a default installed into a container. You might always use
the `sudo apt-get install <package>`, but this is something that
you need to do every time since the containers are reinitialized.

The better way is to add to `gck.env` (do not include quotes!):

```bash
ADDITIONAL_DEPS=gdb strace
```

## Deprecation of `.env`

Due to conflict with `docker-compose`, `GCK` does not allow
to use `.env`. You need to migrate `.env` to `gck.env`,
and each environment variable needs to be prefixed
with `export`:

```bash
export METRICS_TOKEN=3i113EJN5zf4Ng7Nm-mg
```

## Integration with Bash shell

GitLab Compose Kit provides a way to integrate with your local Bash shell.

To enable it, load [`.gck`](.gck) file into your shell. You can do it for example by adding
this at the end of your `~/.bashrc`:

```shell
if [[ -f ~/path/to/gitlab-compose-kit/.gck ]]; then
    source ~/path/to/gitlab-compose-kit/.gck
fi
```

This will add a `gck` command, with following subcommands:

- `gck refresh` - to reload the `.gck` definitions in your shell. It's best to execute it after updating GCK with
  newest version from the remote repository
- `gck cd [argument]` - changes directory to a one specified by the argument, which should be relative to the GitLab
  Compose Kit root directory. For example execute `gck cd gitlab-rails` to switch to the `gitlab-rails` directory
  under the GitLab Compose Kit root directory. If the argument is not specified, `gck cd` will switch the directory
  to GCK root one. This command supports Bash completion.
- `gck [make target]` - all other commands will be "proxied" to Make in context of the GitLab Compose Kit root
  directory. This allows to execute all Make targets without a need of switching to the root directory. For example
  instead of `cd ~/my/projects/gitlab-compose-kit; make up` you can simply call `gck up` which will work exactly the
  same. After finishing the execution of the Make target, the shell context is brought back to the initial directory.
  This command supports Bash completion, however it depends on `make help` target and doesn't show all the commands
  (which mostly means that it will not support `make up-something` and `make down-something`).

## GitLab Cells

The `gitlab-compose-kit` can be conveniently used to simulate [cellular architecture of GitLab](https://docs.gitlab.com/ee/architecture/blueprints/cells/):

- Cells will be accessible on `http://<hostname>:3000` (Cell 1), `http://<hostname>:3001` (Cell 2), etc.
- Cells will share user accounts, and user sessions.
- Cells will have separate repositories.
- Cells will share application source code.
- Cells will share bundle and Go cache.

For that purpose run the following to run GitLab with the Cells:

1. Provision Cells:

    ```bash
    # Provision as many cells as you need
    make create-dev CELL=1
    make create-dev CELL=2
    ```

2. Run Cells interactively via separate terminals:

    ```bash
    # Terminal 1
    make web-and-sidekiq CELL=1
    # Terminal 2
    make web-and-sidekiq CELL=2
    ```

3. Run Cells in background:

    ```bash
    make up CELL=1
    make up CELL=2
    ```

## Author

Kamil Trzciński, 2017, GitLab

## License

MIT
