include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/dotenv
include $(MKPM)/envcache

export DOCKER ?= docker
export BUILDX ?= $(DOCKER) buildx

APPS_LIST=$(shell $(CAT) apps.list)
APPS=$(shell $(ECHO) $(APPS_LIST) | $(SED) 's|=[^ ]*||g')

.PHONY: apps
apps: $(APPS) ## load apps

.SECONDEXPANSION:
.PHONY: $(APPS)
$(APPS): apps/$$@/setup.py
$(patsubst %,apps/%/setup.py,$(APPS)):
	@BRANCH=$(call repo_branch,$(call app_repo,$(patsubst apps/%/setup.py,%,$@))) && \
		$(GIT) clone --depth 1 \
		$$([ "$$BRANCH" = "" ] || $(ECHO) --branch $${BRANCH}) \
		$(call repo_base,$(call app_repo,$(patsubst apps/%/setup.py,%,$@))) \
		apps/$(patsubst apps/%/setup.py,%,$@)

.PHONY: build
build: apps ## build images
	@$(BUILDX) bake

.PHONY: push
push: apps ## push images
	@$(BUILDX) bake --push

.PHONY: purge
purge: ##
	-@$(RM) -rf apps
	-@$(GIT) clean -fxd

export CACHE_ENVS += \

define app_repo
$(shell $(ECHO) $(APPS_LIST) | $(SED) 's| |\n|g' | $(GREP) -E '^$1=' | $(SED) 's|^[^=]*=||g')
endef

define repo_branch
$(shell $(ECHO) "$1" | $(GREP) -oE '#.+' | $(CUT) -c2-)
endef

define repo_base
$(shell $(ECHO) "$1" | $(SED) 's|#.*$$||g')
endef

endif
