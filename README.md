## GitLab Development Kit using Docker Compose

This projects aims to ease GitLab Development,
by enabling the use of minimal containers / micro-services
with minimal set of dependencies.

It currently supports:
- GitLab Rails: Unicorn / Sidekiq,
- GitLab Workhorse,
- Gitaly,
- PostgreSQL,
- Redis.

It allows to:
- Run development environment,

### Requirements

1. Docker Engine,
2. Docker Compose,
3. GNU Make,
4. Linux machine (it might work on Docker for Mac, but not guaranteed).

### How to use it?

#### 1. Run to setup:

```bash
$ make setup
```

This will take long minutes to build base docker image, compile all dependencies,
provision application.

#### 2. Start the development environment (and keep it running in shell):

```bash
$ make up
```

To reload environment simply Ctrl-C and re-run it again :)

**Access GitLab: http://localhost:3000/**

#### 3. Update

```bash
make update
```

This command will:

1. Pull and merge all sources into current branch,
2. Migrate development and test database.

#### 4. Drop into the shell (for tests)

```bash
$ make shell
$ bin/rspec spec/...
```

### 5. Stop environment

```bash
$ make down
```

This will shutdown all containers, releasing all resources.

### 6. Destroy

```bash
$ make destroy
$ rm -rf data/
```

Afterwards you have to run `make setup` again :)

### Author

Kamil Trzciński, 2017, GitLab

### License

MIT
