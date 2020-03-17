print("Welcome to GitLab Compose Kit syncing script...")
print()

if not os.getenv("SSH_TARGET_USER") then
  print("SSH_TARGET_USER not defined")
  os.exit(1)
end

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

rsync_binary = "/usr/bin/rsync"

-- try /usr/local/bin/rsync
local f = io.open("/usr/local/bin/rsync", "r")
if f ~= nil then
  io.close(f)
  rsync_binary = "/usr/local/bin/rsync"
end

base_config = {
  default.rsyncssh,
  exclude = {
    '.git'
  },
  delete = true,

  host = os.getenv("SSH_TARGET_USER") .. "@" .. os.getenv("SSH_TARGET_HOST"),
  rsync = {
    archive = true,
    compress = true,
    whole_file = false,
    binary = rsync_binary
  },

  ssh = {
    options = {
      ControlMaster = "auto",
      ControlPath = ".sync.control",
      ControlPersist = "5m",
      port = os.getenv("SSH_TARGET_PORT")
    }
  },

  prepare = function(config, level)
    default.prepare(config, level + 1)

    config.name = config.source
    config.targetdir = os.getenv("SSH_TARGET_DIR") .. "/" .. config.source
    config.excludeFrom = config.source .. "/.gitignore"
    config.delay = 1
  end
}

root_sync = sync {
  base_config,
  source = ".",
}
root_sync.rmExclude("/gck.yml")

gitaly_sync = sync {
  base_config,
  source = "gitaly",
}

pages_sync = sync {
  base_config,
  source = "gitlab-pages",
}

if os.getenv("ENABLE_GITLAB_RUNNER") then
  runner_sync = sync {
    base_config,
    source = "gitlab-runner",
  }
end

rails_sync = sync {
  base_config,
  source = "gitlab-rails",
}

shell_sync = sync {
  base_config,
  source = "gitlab-shell",
}
shell_sync.rmExclude(".git")

workhorse_sync = sync {
  base_config,
  source = "gitlab-workhorse",
}
