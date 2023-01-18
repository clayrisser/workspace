include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/dotenv
include $(MKPM)/envcache

FRAPPE_BRANCH ?= version-14
PYTHON_VERSION ?= 3.10.5
NODE_VERSION ?= 16.18.0

BASE64 ?= base64
BUILDAH ?= buildah
export APPS_JSON_BASE64=$(shell $(BASE64) --wrap=0 apps.json)

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
			--build-arg=APPS_JSON_BASE64=$(APPS_JSON_BASE64) \
			--tag=$(REGISTRY_NAME):$(VERSION) \
			--file=images/custom/Containerfile .

.PHONY: push
push: ## push images
# 	@$(BUILDX) bake --push

.PHONY: purge
purge: ##
	-@$(RM) -rf apps
	-@$(GIT) clean -fxd

export CACHE_ENVS += \

endif
