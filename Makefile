CI_COMMIT_TAG ?= 1.0.0

.PHONY: all build

PORT_ADMIN = $$(docker port apiplatformtuto_nginx_1 8090/tcp | sed 's/0.0.0.0//')

DOCKER_COMPOSE = docker-compose -p apiplatformtuto -f docker-compose.yml -f docker-compose.dev.yml

CONTAINER_ID_NGINX = $$(docker container ls -f "name=apiplatformtuto_nginx" -q)
CONTAINER_ID_PHP = $$(docker container ls -f "name=apiplatformtuto_php" -q)

NGINX = docker exec -ti $(CONTAINER_ID_NGINX)
PHP = docker exec -ti $(CONTAINER_ID_PHP)

## Colors
COLOR_RESET			= \033[0m
COLOR_ERROR			= \033[31m
COLOR_INFO			= \033[32m
COLOR_COMMENT		= \033[33m
COLOR_TITLE_BLOCK	= \033[0;44m\033[37m

SF_ENV = dev
## Help
help:
	@printf "${COLOR_TITLE_BLOCK}Api platform tuto${COLOR_RESET}\n"
	@printf "\n"
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make [target]\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@awk '/^[a-zA-Z\-\_0-9\@]+:/ { \
		helpLine = match(lastLine, /^## (.*)/); \
		helpCommand = substr($$1, 0, index($$1, ":")); \
		helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
		printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

######### DOCKER COMPOSE COMMANDS #########
port:
	@echo "Frontend is available here: http://localhost$(PORT_ADMIN)/"
docker-kill: ## kill les containers docker
	@$(DOCKER_COMPOSE) kill $(CONTAINER) || true

docker-rm: ## supprime les containers docker
	@$(DOCKER_COMPOSE) rm -f $(CONTAINER) || true

docker-build: ## build les containers docker
	@$(DOCKER_COMPOSE) build --build-arg user_uid=$(shell id -u) $(CONTAINER)

docker-build-no-cache: ## build les containers docker, no caching
	@$(DOCKER_COMPOSE) build --build-arg user_uid=$(shell id -u) --no-cache --pull $(CONTAINER)

docker-up: ## lance les containers docker
	@$(DOCKER_COMPOSE) up $(CONTAINER)

docker-ps:: ## affiche l'état des containers docker
	@$(DOCKER_COMPOSE) ps $(CONTAINER) || true

docker-logs: ## affiche les logs des containers docker
	@$(DOCKER_COMPOSE) logs $(CONTAINER) || true

start: ## lance les containers docker (pas de rebuild)
	@$(DOCKER_COMPOSE) up --force-recreate --build

stop: ## lance les containers docker (pas de rebuild)
	@$(DOCKER_COMPOSE) down

start-daemon:## lance les containers docker (pas de rebuild)
	@$(DOCKER_COMPOSE) up --no-recreate -d
	@echo "Frontend is available here: http://localhost$(PORT_ADMIN)/"

restart: ## lance les containers docker (rebuild après kill et suppression des containers)
restart: docker-kill docker-rm docker-build start

restart-daemon: ## lance les containers docker (rebuild après kill et suppression des containers)
restart-daemon: docker-kill docker-rm docker-build start-daemon

restart-no-cache: ## lance les containers docker (rebuild après kill et suppression des containers)
restart-no-cache: docker-kill docker-rm docker-build-no-cache start

######### CONNECT TO CONTAINERS #########

shell-app:
	@$(DOCKER_COMPOSE) exec php bash

shell-nginx:
	@$(DOCKER_COMPOSE) exec nginx bash

######### COMPOSER #########

composer-install:
	$(PHP) composer install

composer-update:
	$(PHP) composer update

composer-show-installed:
	$(PHP) composer show -i

######### TESTS #########

## prepare CI for testing
prepare-ci:
	composer install --dev

OPTTAGS := $(if $(TAGS),--tags='$(TAGS)',)

NEEDLE=l

######### MISCELLANEOUS #########
cache-clear:
	$(PHP) bin/console cache:clear

init-project: composer-install db-init

######### DATABASE #########

db-init: db-drop db-create db-schema-update

db-connect:
	$(DB) mysql -u root --password=azerty apiplatformtuto

db-drop:
	$(PHP) bin/console doctrine:database:drop --if-exists --force --env=$(SF_ENV)

db-create:
	$(PHP) bin/console doctrine:database:create --if-not-exists --env=$(SF_ENV)

db-dump-updates:
	$(PHP) bin/console doctrine:schema:update --dump-sql --env=$(SF_ENV)

db-schema-update:
	$(PHP) bin/console doctrine:schema:update --force --env=$(SF_ENV)

db-schema-validate:
	$(PHP) bin/console doctrine:schema:validate --env=$(SF_ENV)
