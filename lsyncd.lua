settings {
  nodaemon = true,
  delay = 1,
}

host_config = "root@server.ayufan.eu"
rsync_config = {
  archive = true,
  compress = true,
  whole_file = false
}

ssh_config = {
  options = {
    ControlMaster = "auto",
    ControlPath = ".sync.control",
    ControlPersist = "5m"
  }
}

sync {
  default.rsyncssh,
  source = ".",
  targetdir = "./gitlab-compose-kit",
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
  targetdir = "./gitlab-compose-kit/gitaly",
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
  targetdir = "./gitlab-compose-kit/gitlab-pages",
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
  targetdir = "./gitlab-compose-kit/gitlab-runner",
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
  targetdir = "./gitlab-compose-kit/gitlab-rails",
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
  targetdir = "./gitlab-compose-kit/gitlab-shell",
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
  targetdir = "./gitlab-compose-kit/gitlab-workhorse",
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
