IMAGE_DIR := /Users/ricky/Documents/personal/dreamcatcher-infrastructure/images/fedora43-asus-tuf-a16
RENDER_SCRIPT := $(IMAGE_DIR)/scripts/render-blueprint.sh
GENERATED_DIR := $(IMAGE_DIR)/generated
BLUEPRINT := $(GENERATED_DIR)/asus-tuf-a16-oem-installer.toml
BLUEPRINT_NAME := fedora43-asus-tuf-a16-oem
IMAGE_TYPE := workstation-live-installer

.PHONY: render validate build status image clean

render:
	@mkdir -p $(GENERATED_DIR)
	@bash $(RENDER_SCRIPT) > $(BLUEPRINT)
	@echo "Rendered $(BLUEPRINT)"

validate: render
	@bash -n $(RENDER_SCRIPT)
	@bash -n $(IMAGE_DIR)/files/dreamcatcher-enable-nvidia.sh
	@bash -n $(IMAGE_DIR)/files/dreamcatcher-oem-firstboot.sh
	@test -s $(IMAGE_DIR)/kickstarts/asus-tuf-a16-oem.ks
	@if command -v composer-cli >/dev/null 2>&1; then \
		sudo composer-cli blueprints push $(BLUEPRINT) && \
		sudo composer-cli blueprints depsolve $(BLUEPRINT_NAME); \
	else \
		echo "composer-cli not installed; skipped Image Builder validation"; \
	fi

build: validate
	@if ! command -v composer-cli >/dev/null 2>&1; then \
		echo "composer-cli is required to build the ISO"; \
		exit 1; \
	fi
	@sudo composer-cli compose start $(BLUEPRINT_NAME) $(IMAGE_TYPE)

status:
	@if ! command -v composer-cli >/dev/null 2>&1; then \
		echo "composer-cli is not installed"; \
		exit 1; \
	fi
	@sudo composer-cli compose status

image:
	@if [ -z "$(UUID)" ]; then \
		echo "Set UUID=<compose-uuid>"; \
		exit 1; \
	fi
	@if ! command -v composer-cli >/dev/null 2>&1; then \
		echo "composer-cli is not installed"; \
		exit 1; \
	fi
	@sudo composer-cli compose image $(UUID)

clean:
	@rm -f $(BLUEPRINT)
