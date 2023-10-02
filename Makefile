.PHONY: playbook
playbook: ping ## Deploy playbook
	ansible-playbook playbook.yml --extra-vars @.vars.yml -vv

.PHONY: playbook-k
playbook-k: ping ## Deploy playbook
	ansible-playbook playbook.yml --extra-vars @.vars.yml -vv -K

.PHONY: init
init: ## Init ansible install with venv
	sudo apt update -y && sudo apt-get install sshpass -y
	python3 -m venv venv
	./venv/bin/pip install --no-index --find-links pkg ansible

.PHONY: ping
ping: ## Ping all hosts
	ansible all -m ping

.PHONY: help
help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'