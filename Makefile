.PHONY: build_standalone

build: check-env
	@echo "Building VM $(MACHINE)";
	$(eval BUILD_PATH=$(shell nix-build conf/images.nix --no-out-link --arg machineConfiguration machines/$(MACHINE)/configuration.nix --show-trace))
	cp $(BUILD_PATH)/*.qcow2 ./
	chmod u+w ./*.qcow2

check-env:
ifndef MACHINE
	$(error MACHINE is undefined)
endif
