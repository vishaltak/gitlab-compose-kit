ifneq (,$(CELL))
ifeq ($(shell expr $(CELL) \<= 0), 1)
$(error "The CELL needs to be greater or equal to 1.")
endif

export ORG_COMPOSE_PROJECT_NAME := $(COMPOSE_PROJECT_NAME)
export CUSTOM_REDIS_CLUSTER_STORE ?= sessions cache

ifeq ($(shell expr $(CELL) \> 1), 1)
export COMPOSE_PROJECT_NAME := $(COMPOSE_PROJECT_NAME)_cell_$(CELL)
export CUSTOM_WEB_PORT := $(shell /bin/bash -c "echo $$((3000+$(CELL)-1))")
export CUSTOM_SSH_PORT := $(shell /bin/bash -c "echo $$(($(CUSTOM_SSH_PORT)+$(CELL)-1))")
export CUSTOM_REGISTRY_PORT := $(shell /bin/bash -c "echo $$(($(CUSTOM_REGISTRY_PORT)+$(CELL)-1))")
export CUSTOM_WEBPACK_PORT := $(shell /bin/bash -c "echo $$(($(CUSTOM_WEBPACK_PORT)+$(CELL)-1))")
export CUSTOM_MINIO_CONSOLE_PORT := $(shell /bin/bash -c "echo $$(($(CUSTOM_MINIO_CONSOLE_PORT)+$(CELL)-1))")
endif
endif
