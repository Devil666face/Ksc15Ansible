PACKAGES="python3-apt"
PACK_LIST=$(shell apt-cache depends --recurse --no-recommends --no-suggests \
	  --no-conflicts --no-breaks --no-replaces --no-enhances \
	  --no-pre-depends $(PACKAGES) | grep "^\w")
.DEFAULT_GOAL := help

playbook: ping ## Deploy playbook
	ansible-playbook playbook.yml --extra-vars @.vars.yml -vv \
		--tags "preinstall" \
		--tags "psql" \
		--tags "ksc" \
		--tags "web" 

playbook-k: ping ## Deploy playbook
	ansible-playbook playbook.yml --extra-vars @.vars.yml -vv -K \
		--tags "preinstall" \
		--tags "psql" \
		--tags "ksc" \
		--tags "web" 

playbook-web: ping ## Deploy web
	ansible-playbook playbook.yml --extra-vars @.vars.yml -vv \
		--tags "web" 

init: ## Init ansible install with venv
	sudo apt update -y && sudo apt-get install sshpass -y
	tar -xf .dev/python-3.10.8-debian10.tgz
	tar -xf .dev/pkg.tgz
	./python/bin/python3.10 -m venv venv
	./venv/bin/pip install --no-index --find-links pkg -r requirements.txt
	rm -r pkg

pack:
	mkdir pkg deb
	./venv/bin/pip freeze > requirements.txt
	./venv/bin/pip download -d pkg -r requirements.txt
	tar -cvzf .dev/pkg.tgz pkg
	cd deb && apt-get download $(PACK_LIST) && cd ..
	tar -cvzf .dev/deb.tgz deb
	rm -r pkg deb

ping: ## Ping all hosts
	ansible all -m ping

help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
