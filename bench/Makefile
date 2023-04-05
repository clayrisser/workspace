include ../mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/dotenv

export DOCKER_FLAVOR := docker
export NAME := bench

include $(MKPM)/docker

endif
