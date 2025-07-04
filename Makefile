#!make

SHELL := /bin/bash

ifndef DOCKER_ENV
export DOCKER_ENV=dev
endif

ifndef DOCKER_PWD
export DOCKER_PWD=$(PWD)/docker
endif

# Import .env file
include $(DOCKER_PWD)/conf/.env

# set binary
composer = $(php) php -d memory_limit=-1 /usr/local/bin/composer
console = $(php) php -d memory_limit=-1 bin/console
docker-compose = docker compose -f $(DOCKER_PWD)/compose.yml -f $(DOCKER_PWD)/compose.override.yml -p $(PROJECT_NAME)
node = $(docker-compose) run --rm node
php = $(docker-compose) run --rm web
wp = $(docker-compose) exec -it web wp --path=/var/www/html/public/wp
phpqa = docker run --init --rm -v $(PROJECT_ROOT_DIR):/project -w /project jakzal/phpqa:php8.3
grumphp = docker run --rm -it -v $(PROJECT_ROOT_DIR):/grumphp -w /grumphp webdevops/php:8.3-alpine

# output colors
C_BLACK=\033[0;30m
C_RED=\033[0;31m
C_GREEN=\033[0;32m
C_YELLOW=\033[0;33m
C_BLUE=\033[0;34m
C_PURPLE=\033[0;35m
C_CYAN=\033[0;36m
C_WHITE=\033[0;37m
C_GRAY=\033[0;90m
C_NONE=\033[0m

# set vars
date = $(shell date +'%y%m%d%H%M%S')
config_vars=PROJECT_NAME \
	PROJECT_ROOT_DIR \
	APP_ROOT_DIR \
	THEME_NAME \
	THEME_ROOT_DIR \
	SERVE_BASE_HOST \
	SERVE_WEB_PROXY \
	SERVE_DB_PROXY \
	SERVE_MAIL_PROXY \
	SERVE_TRAEFIK_PROXY \
	LOCAL_UID \
	LOCAL_USERNAME \
	LOCAL_GID \
	LOCAL_HOME \
	LOCAL_DOCKER_IP \
	DB_ENGINE \
	DB_HOST \
	DB_PORT \
	DB_CHARSET \
	DB_SERVER_VERSION \
	DB_ROOT_PASSWORD \
	DB_NAME DB_USER \
	DB_PASSWORD \
	DB_PREFIX \
	ADMIN_USER \
	ADMIN_PASSWORD \
	ADMIN_EMAIL \
	HOME_URL \
	SITE_TITLE \
	NGROK_AUTHTOKEN \
	EXPOSE_SHARE_TOKEN

# default target
.DEFAULT_GOAL := help

##@ General
.PHONY: help
help: ## ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\n${PROJECT_NAME} ${C_GREEN}${APP_RELEASE}${C_NONE}\n\nUsage:\n  make ${C_BLUE}<target>${C_NONE}\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  ${C_GREEN}%-25s${C_NONE} %s\n", $$1, $$2 } /^##@/ { printf "\n${C_YELLOW}%s${C_NONE}\n", substr($$0, 5) } /^##\?/ { printf "  ${C_GRAY}%s${C_NONE}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: info
info: ## Show services info.
	@printf "\n${PROJECT_NAME} ${C_GREEN}${APP_RELEASE}${C_NONE}\n"
	@printf "\n${C_CYAN}WEB FRONT APPLICATION${C_NONE}\n"
	@printf "   http://${SERVE_WEB_PROXY} ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" http://${SERVE_WEB_PROXY})]${C_NONE}\n"
	@printf "   https://${SERVE_WEB_PROXY} ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVE_WEB_PROXY})]${C_NONE}\n"
	@printf "   http://$$(make ip container=web -s) ${C_GRAY}[$$(curl -s -o /dev/null -w "%{http_code}" http://$$(make ip container=web -s))]${C_NONE}\n"
	@printf "\n${C_CYAN}WEB ADMIN APPLICATION${C_NONE}\n"
	@printf "   http://${SERVE_WEB_PROXY}/wp/wp-admin ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" http://${SERVE_WEB_PROXY}/wp/wp-admin)]${C_NONE}\n"
	@printf "   https://${SERVE_WEB_PROXY}/wp/wp-admin ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVE_WEB_PROXY}/wp/wp-admin)]${C_NONE}\n"
	@printf "   http://$$(make ip container=web -s)/wp/wp-admin ${C_GRAY}[$$(curl -s -o /dev/null -w "%{http_code}" http://$$(make ip container=web -s)/wp/wp-admin)]${C_NONE}\n"
	@printf "   \n"
	@printf "   ${C_PURPLE}DEVELOPMENT CONNEXION INFORMATIONS:${C_NONE}\n"
	@printf "   ${C_GREEN}Admin user:${C_NONE}			${ADMIN_USER}\n"
	@printf "   ${C_GREEN}Admin email:${C_NONE}			${ADMIN_EMAIL}\n"
	@printf "   ${C_GREEN}Admin password:${C_NONE}		${ADMIN_PASSWORD}\n"
	@printf "\n${C_CYAN}DB MANAGER${C_NONE}\n"
	@printf "   https://${SERVE_DB_PROXY} ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVE_DB_PROXY})]${C_NONE}\n"
	@printf "   http://$$(make ip container=adminer -s):8080 ${C_GRAY}[$$(curl -s -o /dev/null -w "%{http_code}" http://$$(make ip container=adminer -s):8080)]${C_NONE}\n"
	@printf "\n${C_CYAN}MAIL CATCHER${C_NONE}\n"
	@printf "   https://${SERVE_MAIL_PROXY} ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVE_MAIL_PROXY})]${C_NONE}\n"
	@printf "   http://$$(make ip container=mail -s):8025 ${C_GRAY}[$$(curl -s -o /dev/null -w "%{http_code}" http://$$(make ip container=mail -s):8025)]${C_NONE}\n"
	@printf "\n${C_CYAN}TRAEFIK${C_NONE}\n"
	@printf "   https://${SERVE_TRAEFIK_PROXY} ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVE_TRAEFIK_PROXY})]${C_NONE}\n"
	@printf "   http://$$(make ip container=traefik -s):8080 ${C_GRAY}[$$(curl -k -s -o /dev/null -w "%{http_code}" http://$$(make ip container=traefik -s):8080)]${C_NONE}\n"
	@printf "\n${C_CYAN}DATABASE${C_NONE}\n"
	@printf "   ${C_GREEN}Engine:${C_NONE}		${DB_ENGINE}\n"
	@printf "   ${C_GREEN}Host:${C_NONE}		`make ip container=db -s`\n"
	@printf "   ${C_GREEN}Port:${C_NONE}		${DB_PORT}\n"
	@printf "   ${C_GREEN}Name:${C_NONE}		${DB_NAME}\n"
	@printf "   ${C_GREEN}User:${C_NONE}		${DB_USER}\n"
	@printf "   ${C_GREEN}Password:${C_NONE}		${DB_PASSWORD}\n"
	@printf "   ${C_GREEN}DSN:${C_NONE}			${DB_ENGINE}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}\n"

.PHONY: ip
ip: ## Show container IP.
	@docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $$($(docker-compose) ps -aq ${or ${container}, web})
##? [container="{{ name }}"]	Service name, php by default.

.PHONY: ips
ips: ## Show container IPs.
	@for CONTAINER in $$(docker container ls --filter name=$(PROJECT_NAME) | awk '{print $$NF}' | awk 'NR > 1'); do echo -e "${C_GREEN}$$CONTAINER${C_NONE}" $$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $$CONTAINER); done | column -t

.PHONY: open
open: ## Open browser
	@nohup xdg-open https://${SERVE_WEB_PROXY} > /dev/null 2>&1

##@ Install
.PHONY: init ## Initialize application.
init: up init-install init-create init-config init-dependencies init-wp info

.PHONY: init ## Clean, flush and  renew initialization.
reinit: init-clean down init

.PHONY: init-install ## Install dependencies.
init-install:
	@$(composer) install

.PHONY: init-create
init-create: ## Download and install Roots/Sage.
	@$(docker-compose) exec -ti web bash -c '/usr/local/bin/composer create-project roots/sage public/app/themes/${THEME_NAME} --no-interaction --no-progress --prefer-dist'

.PHONY: init-config
init-config: ## Finalize Roots/Sage configuration.
	@$(docker-compose) exec -ti web bash -c "sed -ri -e 's!/app/themes/sage/public/build/!/app/themes/${THEME_NAME}/public/build/!g' /var/www/html/public/app/themes/${THEME_NAME}/vite.config.js"

.PHONY: init-dependencies
init-dependencies: ## Install application dependencies.
	@make npm CMD="install"
	@make npm CMD="run build"

.PHONY: install-wp
init-wp:  ## Init wordpress application (install database and activate theme).
	@$(wp) core install --url=${HOME_URL} --title='${SITE_TITLE}' --admin_user=${ADMIN_USER} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL}
	@$(wp) theme activate ${THEME_NAME}

init-clean: ## Clean initialization to allow renewing.
	@rm -rf $(THEME_ROOT_DIR) $(APP_ROOT_DIR)/vendor $(APP_ROOT_DIR)/public/wp

.PHONY: install
install: build up install-dependencies install-database post-install info ## ## Installing project

.PHONY: install-dependencies
install-dependencies: ## @todo Install application dependencies.
#	@$(composer) install --no-interaction --no-progress --optimize-autoloader --prefer-dist
#	@make yarn CMD="install"
#	@make yarn CMD="build"

.PHONY: install-database
install-database: ## @todo Install application database.
#	@make up container=db
#	@make db-import FILE=$(DOCKER_PWD)/data/postgres/install.sql.gz
#	@$(console) doctrine:migrations:migrate --allow-no-migration --no-interaction --quiet

.PHONY: post-install
post-install: ## @todo Execute post-install scripts.
#	@$(docker-compose) exec -u ${LOCAL_USERNAME} web /bin/bash app/scripts/post-install.sh

.PHONY: uninstall
uninstall: clean ## @todo Uninstall application.
#	@$(docker-compose) down --remove-orphans ${or ${container}, -v}
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: reinstall
reinstall: uninstall install ## Reinstall application.

.PHONY: clean
clean: ## Remove application dependencies.

.PHONY: start
start: up install-dependencies post-install info ## Start application.

.PHONY: restart
restart: stop start ## Restart application.

##@ Docker
.PHONY: build
build: ## Build docker images.
	@$(docker-compose) build $(container)
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: rebuild
rebuild: ## Rebuild docker images.
	@$(docker-compose) build --no-cache $(container)
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: up
up: ## (Re-)Create and start containers.
	@$(docker-compose) up -d --remove-orphans $(container)
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: down
down: ## (Re-)Create and start containers.
	@$(docker-compose) down $(container) ${or ${CMD}, --volumes}

.PHONY: stop
stop: ## Stop containers.
	@$(docker-compose) stop $(container)
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: respawn
respawn: stop up ## Stop and up containers.
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: ps
ps: ## List containers status.
	@$(docker-compose) ps $(container)
##? [container="{{ name }}"]	For only one container by it service name.

.PHONY: logs
logs: ## Show containers logs.
	@$(docker-compose) logs -f $(container)
##? [container="{{ name }}"]	For only one container by it service name.

##@ Configuration
.PHONY: config
config: ## Print list of configuration variables.
	@for var in $(config_vars); do \
		echo "$$var=$${!var}"; \
	done

.PHONY: config-get
config-get: guard-VAR ## Print one configuration variable.
	@echo ${if ${VAR}, "$$VAR=$${!VAR}", '"var" arg is required'}
##? [VAR="{{ name }}"]		Required environment variable name.

.PHONY: config-set
config-set: guard-VAR guard-VAL ## Set a customized configuration variable.
	@VAR=$(VAR); \
	VALUE=$(VAL); \
	FILE=.config.env; \
	if [ ! -f $$FILE ]; then \
		touch $$FILE; \
	fi; \
	if grep -q "^export $$VAR=" $$FILE; then \
		if sed --version >/dev/null 2>&1; then \
			# GNU sed (Linux) \
			sed -i "s|^export $$VAR=.*|export $$VAR=$$VAL|" $$FILE; \
		else \
			# BSD sed (macOS) \
			sed -i '' "s|^export $$VAR=.*|export $$VAR=$$VAL|" $$FILE; \
		fi; \
	else \
		echo "export $$VAR=$$VAL" >> $$FILE; \
	fi; \
	echo "✅ $$VAR set to '$$VAL' in $$FILE"

##@ Utils
.PHONY: bash
bash: ## Open a container bash.
	@$(docker-compose) exec -u ${or ${user}, root} ${or ${container}, web} /bin/bash
##? [container="{{ name }}"]	Service name, [web] by default.
##? [user="{{ name }}"]		User name, [root] by default.

.PHONY: sh
sh: ## Open a container shell.
	@$(docker-compose) exec -u ${or ${user}, root} ${or ${container}, web} /bin/sh
##? [container="{{ name }}"]	Service name, [web] by default.
##? [user="{{ name }}"]		User name, [root] by default.

.PHONY: php
php: ## Launch a PHP command.
	@$(php) php ${or ${CMD}, -v}
##? [CMD="{{ command }}"]		[-v] by default.

.PHONY: composer
composer: ## Launch composer command.
	@$(composer) ${or ${CMD}, list}
##? [CMD="{{ command }}"]		[list] by default.

.PHONY: wp
wp: ## Launch Symfony console command.
	@$(wp) ${or ${CMD}, --info}
##? [CMD="{{ command }}"]		[list] by default.

.PHONY: mailer
mailer: ## @todo Open a terminal to test mail send.
	@curl -X POST "http://`make ip container=mail -s`:8025/api/v1/send" \
     -H 'accept: application/json'\
     -H 'content-type: application/json' \
     -d '{"Attachments":[{"Content":"iVBORw0KGgoAAAANSUhEUgAAAEEAAAA8CAMAAAAOlSdoAAAACXBIWXMAAAHrAAAB6wGM2bZBAAAAS1BMVEVHcEwRfnUkZ2gAt4UsSF8At4UtSV4At4YsSV4At4YsSV8At4YsSV4At4YsSV4sSV4At4YsSV4At4YtSV4At4YsSV4At4YtSV8At4YsUWYNAAAAGHRSTlMAAwoXGiktRE5dbnd7kpOlr7zJ0d3h8PD8PCSRAAACWUlEQVR42pXT4ZaqIBSG4W9rhqQYocG+/ys9Y0Z0Br+x3j8zaxUPewFh65K+7yrIMeIY4MT3wPfEJCidKXEMnLaVkxDiELiMz4WEOAZSFghxBIypCOlKiAMgXfIqTnBgSm8CIQ6BImxEUxEckClVQiHGj4Ba4AQHikAIClwTE9KtIghAhUJwoLkmLnCiAHJLRKgIMsEtVUKbBUIwoAg2C4QgQBE6l4VCnApBgSKYLLApCnCa0+96AEMW2BQcmC+Pr3nfp7o5Exy49gIADcIqUELGfeA+bp93LmAJp8QJoEcN3C7NY3sbVANixMyI0nku20/n5/ZRf3KI2k6JEDWQtxcbdGuAqu3TAXG+/799Oyyas1B1MnMiA+XyxHp9q0PUKGPiRAau1fZbLRZV09wZcT8/gHk8QQAxXn8VgaDqcUmU6O/r28nbVwXAqca2mRNtPAF5+zoP2MeN9Fy4NgC6RfcbgE7XITBRYTtOE3U3C2DVff7pk+PkUxgAbvtnPXJaD6DxulMLwOhPS/M3MQkgg1ZFrIXnmfaZoOfpKiFgzeZD/WuKqQEGrfJYkyWf6vlG3xUgTuscnkNkQsb599q124kdpMUjCa/XARHs1gZymVtGt3wLkiFv8rUgTxitYCex5EVGec0Y9VmoDTFBSQte2TfXGXlf7hbdaUM9Sk7fisEN9qfBBTK+FZcvM9fQSdkl2vj4W2oX/bRogO3XasiNH7R0eW7fgRM834ImTg+Lg6BEnx4vz81rhr+MYPBBQg1v8GndEOrthxaCTxNAOut8WKLGZQl+MPz88Q9tAO/hVuSeqQAAAABJRU5ErkJggg==","ContentID":"mailpit-logo","ContentType":"image/png","Filename":"mailpit.png"}],"Bcc":["jack@example.com"],"Cc":[{"Email":"manager@example.com","Name":"Manager"}],"From":{"Email":"john@example.com","Name":"John Doe"},"HTML":"<div style=\"text-align:center\"><p style=\"font-family: arial; font-size: 24px;\">Mailpit is <b>awesome</b>!</p><p><img src=\"cid:mailpit-logo\" /></p></div>","Headers":{"X-IP":"1.2.3.4"},"ReplyTo":[{"Email":"secretary@example.com","Name":"Secretary"}],"Subject":"Mailpit message via the HTTP API","Tags":["Tag 1","Tag 2"],"Text":"Mailpit is awesome!","To":[{"Email":"jane@example.com","Name":"Jane Doe"}]}'

.PHONY: share
share: guard-NGROK_AUTHTOKEN ## Publicly expose app on the web with nGrok (NGROK_AUTHTOKEN required).
	@$(docker-compose) run --rm -p 4040:4040 -e NGROK_AUTHTOKEN=${NGROK_AUTHTOKEN} ngrok http ${or ${server}, http://`make ip container=web -s`}
##? [server="{{ server }}"]		expose web service by default.

.PHONY: expose
expose: guard-EXPOSE_SHARE_TOKEN ## Publicly expose app on the web with expose.dev (EXPOSE_SHARE_TOKEN required).
	@$(docker-compose) run --rm -p 4040:4040 expose share --auth=${EXPOSE_SHARE_TOKEN} -- ${or ${server}, "http://`make ip container=web -s`"}
##? [server="{{ server }}"]		expose web service by default.

##@ NodeJS
.PHONY: node
node:  ## Launch a NodeJS command.
	@$(node) ${or ${CMD}, -h}
##? [CMD="{{ command }}"]		[-h] by default.

.PHONY: npm
npm: $(THEME_ROOT_DIR)/package.json $(wildcard $(THEME_ROOT_DIR)/package-lock.json) ## Launch a NPM command.
	@$(node) npm ${or ${CMD}, help}
##? [CMD="{{ command }}"]		[help] by default.

.PHONY: npx
npx: ## Launch a NPX command.
	@$(node) npx ${or ${CMD}, -h}
##? [CMD="{{ command }}"]		[-h] by default.

.PHONY: yarn
yarn: $(THEME_ROOT_DIR)/package.json $(wildcard $(THEME_ROOT_DIR)/package-lock.json) ## Launch a YARN command.
	@$(node) yarn ${or ${CMD}, -h}
##? [CMD="{{ command }}"]		[-h] by default.

.PHONY: pnpm
pnpm: $(APP_ROOT_DIR)/package.json $(wildcard $(APP_ROOT_DIR)/package-lock.json) ## Launch a PNPM command.
	@$(node) pnpm ${or ${CMD}, -h}
##? [CMD="{{ command }}"]		[-h] by default.

##@ Database
.PHONY: db-import
db-import: guard-FILE ## Import a database.
	@echo Importing ${FILE} in database ; \
	case "${FILE}" in \
		*.sql) $(docker-compose) cp "${FILE}" db:/tmp/import.sql && $(docker-compose) exec -ti db bash -c 'pv /tmp/import.sql | mariadb -p"$$MYSQL_ROOT_PASSWORD" "$$MYSQL_DATABASE"' ;; \
		*.sql.gz) $(docker-compose) cp "${FILE}" db:/tmp/import.sql.gz && $(docker-compose) exec -ti db bash -c 'gunzip -f /tmp/import.sql.gz && pv /tmp/import.sql | mariadb -p"$$MYSQL_ROOT_PASSWORD" "$$MYSQL_DATABASE"' ;; \
	esac \
##? [FILE="{{ file_path }}"]		*required.

.PHONY: db-dump
db-dump: ## Dump the database.
	@make up container=db
	@mkdir -p $(APP_ROOT_DIR)/var/db/dump/
	@$(docker-compose) exec -ti db bash -c 'mariadb-dump -p"$$MYSQL_ROOT_PASSWORD" "$$MYSQL_DATABASE" | pv > /tmp/dump.sql'
	@$(docker-compose) cp db:/tmp/dump.sql $(APP_ROOT_DIR)/var/db/dump/dump-$(date).sql

#### Utils
guard-%:
	@#$(or ${$*}, $(error $* is not set))
