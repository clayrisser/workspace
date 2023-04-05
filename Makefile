include mkpm.mk

ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/mkchain
include $(MKPM)/dotenv
include $(MKPM)/envcache

DOCKER_CREDENTIAL_PASS ?= docker-credential-pass
define gitlab_token
$(shell GITLAB_TOKEN=$$($(CAT) $(HOME)/.docker/config.json 2>$(NULL) | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth // ""' | $(BASE64_NOWRAP) -d | $(CUT) -d':' -f2); \
if [ "$$GITLAB_TOKEN" = "" ]; then \
	GITLAB_TOKEN=$$($(ECHO) registry.gitlab.com | $(DOCKER_CREDENTIAL_PASS) get | $(JQ) -r '.Secret'); \
fi; \
$(ECHO) $$GITLAB_TOKEN)
endef

FRAPPE_BRANCH ?= version-14
PYTHON_VERSION ?= 3.10.10
NODE_VERSION ?= 16.18.1

DOCKER ?= docker
BUILDAH ?= buildah
BASE64_NOWRAP = base64 --wrap=0

.PHONY: submodules
ifeq (,$(shell $(LS) .git/modules $(NOFAIL)))
submodules:
	@git submodule update --init --recursive
else
submodules: ;
endif

.PHONY: build
build: submodules ## build images
	@cd frappe_docker && \
		$(BUILDAH) build \
			--build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
			--build-arg=FRAPPE_BRANCH=$(FRAPPE_BRANCH) \
			--build-arg=PYTHON_VERSION=$(PYTHON_VERSION) \
			--build-arg=NODE_VERSION=$(NODE_VERSION) \
			--build-arg=APPS_JSON_BASE64=$(shell $(SED) 's|<GITLAB_TOKEN>|$(call gitlab_token)|g' apps.json | $(BASE64_NOWRAP)) \
			--tag=$(REGISTRY_NAME):$(VERSION) \
			--file=images/custom/Containerfile .

.PHONY: push
push: ## push images
	@$(BUILDAH) push $(REGISTRY_NAME):$(VERSION)

.PHONY: clean
clean: | sudo ##
	$(DOCKER) rm -f $$($(DOCKER) ps -aq)
	$(ECHO) y | $(DOCKER) volume prune
	$(ECHO) y | $(DOCKER) network prune
	@$(SUDO) $(RM) -rf development/frappe-bench
	-@$(MKCACHE_CLEAN)
	-@$(GIT) clean -fXd \
		$(MKPM_GIT_CLEAN_FLAGS) \
		$(NOFAIL)

.PHONY: purge
purge: | sudo clean ##
	-@$(RM) -rf apps
	-@$(GIT) clean -fxd

export CACHE_ENVS += \
	DOCKER \
	BUILDAH \
	BASE64_NOWRAP

-include $(call actions)

endif
