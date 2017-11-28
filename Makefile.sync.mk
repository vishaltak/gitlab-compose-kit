sync: repos
	./scripts/ssh mkdir -p "$(SSH_TARGET_DIR)"
	lsyncd lsyncd.lua
