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
  -- delay = 1,
}

base_config = {
  default.rsyncssh,
  exclude = {
    '.git'
  },
  delete = true,

  host = os.getenv("SSH_TARGET_HOST"),
  rsync = {
    archive = true,
    compress = true,
    whole_file = false,
    binary = "/usr/local/bin/rsync"
  },

  ssh = {
    options = {
      ControlMaster = "auto",
      ControlPath = ".sync.control",
      ControlPersist = "5m",
      port = os.getenv("SSH_TARGET_PORT")
    }
  }
}

root_sync = sync {
  base_config,
  source = ".",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/.",
  excludeFrom = ".gitignore"
}
root_sync.rmExclude("/gitlab.yml")

sync {
  base_config,
  source = "gitaly",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitaly",
  excludeFrom = "gitaly/.gitignore",
}

sync {
  base_config,
  source = "gitlab-pages",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-pages",
  excludeFrom = "gitlab-pages/.gitignore",
}

if os.getenv("ENABLE_GITLAB_RUNNER") then
  sync {
    base_config,
    source = "gitlab-runner",
    targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-runner",
    excludeFrom = "gitlab-runner/.gitignore",
  }
end

sync {
  base_config,
  source = "gitlab-rails",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-rails",
  excludeFrom = "gitlab-rails/.gitignore",
}

sync {
  base_config,
  source = "gitlab-shell",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-shell",
  excludeFrom = "gitlab-shell/.gitignore",
}

sync {
  base_config,
  source = "gitlab-workhorse",
  targetdir = os.getenv("SSH_TARGET_DIR") .. "/gitlab-workhorse",
  excludeFrom = "gitlab-workhorse/.gitignore",
}
