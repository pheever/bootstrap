SHELL := /bin/bash
export PATH := /home/linuxbrew/.linuxbrew/bin:$(PATH)

STOW_PACKAGES := $(filter-out scripts,$(patsubst %/,%,$(wildcard */)))

.PHONY: restow sync-brew stage pull status bootstrap sync

restow: ## Re-run stow for all packages
	@for pkg in $(STOW_PACKAGES); do \
		echo "Restowing $$pkg..."; \
		stow --restow --target="$$HOME" "$$pkg"; \
	done
	@echo "All packages restowed."

sync-brew: ## Dump current brew list to Brewfile
	brew bundle dump --force --file=Brewfile
	@echo "Brewfile updated."

stage: ## Stage all changes (no commit — GPG passphrase needed for signing)
	git add -A
	@echo "Changes staged. Run 'git commit' to commit (GPG passphrase required)."

pull: ## Pull latest changes and restow
	git pull
	@$(MAKE) restow

status: ## Show changed files
	@git status --short

sync: restow sync-brew stage ## Restow, dump Brewfile, and stage all changes

bootstrap: ## Run full bootstrap
	bash bootstrap.sh
