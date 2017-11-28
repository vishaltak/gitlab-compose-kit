print("Welcome to GitLab Compose Kit syncing script...")
print()

if not os.getenv("SSH_TARGET_HOST") then
  print("SSH_TARGET_HOST not defined")
  os.exit(1)
end

if not os.getenv("SSH_TARGET_DIR") then
  print("SSH_TARGET_DIR not defined")
  os.exit(1)
end

settings {
  nodaemon = true,
  delay = 1,
}

host_config = os.getenv("SSH_TARGET_HOST")
rsync_config = {
  archive = true,
  compress = true,
  whole_file = false
}

ssh_config = {
  options = {
    ControlMaster = "auto",
    ControlPath = ".sync.control",
    ControlPersist = "5m",
    port = os.getenv("SSH_TARGET_PORT")
  }
}

sync {
  default.rsyncssh,
  source = ".",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/.",
  excludeFrom = ".gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitaly",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitaly",
  excludeFrom = "gitaly/.gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitlab-pages",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-pages",
  excludeFrom = "gitlab-pages/.gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitlab-runner",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-runner",
  excludeFrom = "gitlab-runner/.gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitlab-rails",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-rails",
  excludeFrom = "gitlab-rails/.gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitlab-shell",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-shell",
  excludeFrom = "gitlab-shell/.gitignore",
  exclude = {
    '.git'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}

sync {
  default.rsyncssh,
  source = "gitlab-workhorse",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-workhorse",
  excludeFrom = "gitlab-workhorse/.gitignore",
  exclude = {
    '.git',
    '/.gitlab_workhorse_secret',
    '/config.toml'
  },
  delete = true,

  host = host_config,
  rsync = rsync_config,
  ssh = ssh_config
}
