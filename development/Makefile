include ../mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/mkchain
include $(MKPM)/envcache
include $(MKPM)/dotenv

SITE_NAME ?= site1.localhost

BENCH ?= bench

.PHONY: install
install:
	@(echo default; echo frappe-bench; echo $(SITE_NAME)) | bash ./installer.sh

-include $(call actions)

CACHE_ENVS += \
	BENCH

endif
