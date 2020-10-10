SELF := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

# Make sure fully-featured BASH shell is used by this Makefile
SHELL := $(shell which bash)

IMAGE := macos-simple-kvm

DISK_NAME ?= MyDisk
DISK_SIZE ?= 64G

# Embed helper Dockerfile here for simplicity
define DOCKERFILE
FROM ubuntu:rolling

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -q update -y \
 && apt-get -q install -y \
    qemu-system \
    qemu-utils \
    python3 \
    python3-pip \
 && apt-get -q autoremove -y \
 && apt-get -q clean -y \
 && rm -rf /var/lib/apt/lists/*

WORKDIR $(SELF)/

ENTRYPOINT []
CMD /bin/bash
endef

# Define helper docker-run macro to simplify rest of the Makefile
define RUN
docker run --rm \
    --network="host" \
    --privileged="true" \
    --device="/dev/dri/" \
    -e DISPLAY="$$DISPLAY" \
    -v $(SELF)/:$(SELF)/ \
    -i $(IMAGE)
endef

# Append audio and hard disk device configuration
define BASIC_SH
$(file < $(SELF)/basic.sh)
-audiodev driver=pa,id=sound1,server=localhost \
-drive id=SystemDisk,if=none,file=MyDisk.qcow2 \
-device ide-hd,bus=sata.4,drive=SystemDisk
endef

export

.PHONY: all

all: basic

.PHONY: build

build:
	docker build -t $(IMAGE) - <<< "$$DOCKERFILE"

.PHONY: jumpstart

jumpstart-%: build
	[[ -f $(SELF)/BaseSystem.img ]] || $(call RUN) ./jumpstart.sh --$*

jumpstart: jumpstart-catalina

.PHONY: basic

basic: build $(SELF)/BaseSystem.img $(SELF)/MyDisk.qcow2
	$(call RUN) bash -s <<< "$$BASIC_SH"

$(SELF)/BaseSystem.img:
	@echo "Please run one of the 'jumpstart' variants first!" && exit 1

$(SELF)/$(DISK_NAME).qcow2:
	$(call RUN) qemu-img create -f qcow2 $@ $(DISK_SIZE)
