SUDO := sudo
PODMAN := $(SUDO) podman
IMAGE := quay.io/heliumos/bootc
IS_CANARY := true
IS_EDGE := false
VERSION := 10
ARCH := x86_64

TAG := $(VERSION)
ifeq ($(IS_CANARY),true)
	TAG := $(TAG)-canary
endif
ifeq ($(IS_EDGE),true)
	TAG := $(TAG)-edge
endif

PLAYBOOK := $(VERSION)
ifeq ($(IS_EDGE),true)
	PLAYBOOK := $(PLAYBOOK)-edge
endif

.PHONY: echo-image echo-tag image rechunk push iso

echo-image:
	@echo $(IMAGE)

echo-tag:
	@echo $(TAG)

image:
	$(PODMAN) build \
		--build-arg BASE=quay.io/almalinuxorg/almalinux-bootc:$(VERSION) \
		--build-arg PLAYBOOK=$(PLAYBOOK).yaml \
		--network host \
		-f Containerfile \
		-t $(IMAGE):$(TAG) \
		.

RECHUNK_DIR := .rechunked
RECHUNK_TAG := chunked

rechunk:
	$(SUDO) rm -rf $(RECHUNK_DIR)
	mkdir -p $(RECHUNK_DIR)
	echo '{"imageLayoutVersion":"1.0.0"}' > $(RECHUNK_DIR)/oci-layout
	echo '{"schemaVersion":2,"manifests":[]}' > $(RECHUNK_DIR)/index.json
	$(PODMAN) run \
		--rm \
		--privileged \
		-v /var/lib/containers:/var/lib/containers \
		-v /var/tmp:/var/tmp \
		-v $(CURDIR)/$(RECHUNK_DIR):/out \
		quay.io/almalinuxorg/almalinux-bootc:$(VERSION) \
		rpm-ostree experimental compose build-chunked-oci \
			--bootc \
			--format-version=1 \
			--max-layers=100 \
			--from=$(IMAGE):$(TAG) \
			--output=oci:/out:$(RECHUNK_TAG)

push:
	$(SUDO) skopeo copy \
		oci:$(CURDIR)/$(RECHUNK_DIR):$(RECHUNK_TAG) \
		docker://$(IMAGE):$(TAG)

iso:
	$(SUDO) rm -rf ./out
	mkdir ./out

	cp \
		./iso/config.toml \
		./out/config.toml

	sed -i \
    "s,<URL>,$(IMAGE):$(TAG),g" \
    ./out/config.toml

	$(PODMAN) pull $(IMAGE):$(TAG)

	$(PODMAN) run \
		--rm \
		-it \
		--net host \
		--privileged \
		--pull=newer \
		--security-opt label=type:unconfined_t \
		-v ./out/config.toml:/config.toml:ro \
		-v ./out:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:sha256-12b08293b340613061e81414b67e1dbf76a47f8f9c631f94f27e4da99dfe757d \
		--type anaconda-iso \
		--use-librepo=False \
		$(IMAGE):$(TAG)

	sudo mv \
	    ./out/bootiso/install.iso \
		./out/upstream.iso

	$(PODMAN) run \
		--rm \
		-it \
		--pull=newer \
		--privileged \
		-v ./out:/output \
		-v ./iso:/iso \
		quay.io/almalinuxorg/almalinux:10.1 \
		bash -c '\
			dnf install -y lorax \
		&& rm -rf /images && mkdir /images \
		&& rm -f /output/HeliumOS-${VERSION}-${ARCH}-boot.iso \
		&& cd /iso/product && find . | cpio -c -o | gzip -9cv > /images/product.img && cd / \
		&& mkksiso \
			--add /images \
			--volid heliumos-${VERSION}-boot \
			--replace "vmlinuz" "vmlinuz inst.resolution=1280x800" \
			/output/upstream.iso \
			/output/HeliumOS-${VERSION}-${ARCH}-boot.iso'
