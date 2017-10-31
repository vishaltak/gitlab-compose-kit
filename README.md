## GitLab Development Kit using Docker Compose

This projects aims to ease GitLab Development,
by enabling the use of minimal containers / micro-services
with minimal set of dependencies.

### Features

It currently supports:
- GitLab Rails: Unicorn / Sidekiq,
- GitLab Workhorse,
- Gitaly,
- PostgreSQL,
- Redis,
- SSH

It allows to:
- Run development environment,
- Run tests,
- Easily teardown and start a new environment.

How it differs from GitLab Development Kit it uses containers for everything,
starting from scratch, building minimal container per application.
Everything has it's own container:
- Unicorn,
- Sidekiq,
- Workhorse,
- Gitaly,
- PostgreSQL,
- Redis,
- Webpacks,
- OpenSSH,
- Registry

The containers interact via HTTP/TCP using intra-container networking.
There's also a shared volume `/home/git` between: Unicorn, Sidekiq, Workhorse, Gitaly and OpenSSH.

It still doesn't support:
- Pages

However, this is super-easy to add now!

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

**Access GitLab: http://localhost:3000/**

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

### Author

Kamil Trzciński, 2017, GitLab

### License

MIT
