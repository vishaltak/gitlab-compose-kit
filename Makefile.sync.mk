sync: repos
ifneq (,$(wildcard /dev/fsevents))
	@echo "lsyncd on OSX requires sudo access"
	sudo -E bash -c 'source .env && ./scripts/ssh mkdir -p "$$SSH_TARGET_DIR/data" && echo OK'
	sudo -E ./scripts/env lsyncd lsyncd.lua
else
	bash -c 'source .env && ./scripts/ssh mkdir -p "$$SSH_TARGET_DIR/data" && echo OK'
	./scripts/env lsyncd lsyncd.lua
endif
