sync: repos
	@bash -c 'source .env && ./scripts/ssh mkdir -p "$$SSH_TARGET_DIR" && echo OK'
	./scripts/env lsyncd lsyncd.lua
