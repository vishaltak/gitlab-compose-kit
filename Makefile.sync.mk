sync: repos
	@bash -c 'source .env && ./scripts/ssh mkdir -p "$$SSH_TARGET_DIR/data" && echo OK'
ifneq (,$(wildcard /dev/fsevents))
	@echo "lsyncd on OSX requires sudo access"
	sudo ./scripts/env lsyncd lsyncd.lua
else
	./scripts/env lsyncd lsyncd.lua
endif
