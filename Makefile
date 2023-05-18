# Project: Dockerized CotizadorSoriana SPA 
# Version: 2.0.0
# Author: Cesar Suarez Granados
# Date: 2023-05-17
# Description: Makefile for Dockerized Laravel 8 with Nginx, MariaDB, NodeJS and Vue 2
# License: MIT
# Usage: make [command]
# Commands:
# 	help: Shows available commands with description

# Determine if FILE_ENV is set && not empty, if empyt exit with error message
ifneq ("$(wildcard .env.make)","")
	include .env.make
else ifneq ("$(wildcard .env.make.example)","")
	include .env.make.example
else
$(error .env.make file does not exist, please create it from .env.make.example file)
endif

ifndef FILE_ENV
$(error FILE_ENV is not set, please set it in .env.make file, valid values are dev, test, staging, prod)
endif

# Determine if .env file exist
ifneq ("$(wildcard .env.$(FILE_ENV))","")
	include .env.$(FILE_ENV)
else
$(error .env.$(FILE_ENV) file does not exist, please create it from .env.$(FILE_ENV) file)
endif

ifndef INSIDE_DOCKER_CONTAINER
	INSIDE_DOCKER_CONTAINER = 0
endif

UID := $(shell id -u)
GID := $(shell id -g)
PHP_USER := -u $(USER)
# Determine if APP_ENV is set && not empty, if empyt exit with error message
ifndef APP_ENV
$(error APP_ENV is not set, please set it in .env file, valid values are dev, test, staging, prod)
endif

# If APP_ENV is prod, PROJECT_NAME set APP_NAME, else set APP_NAME + APP_ENV + VERSION
ifeq ($(APP_ENV), prod)
	PROJECT_NAME := -p $(APP_NAME)
	COMPOSE_PROJECT_NAME := $(APP_NAME)
else
#ifeq ($(APP_ENV), staging, test, dev)
ifneq ($(filter $(APP_ENV),qa dev "preprod"),)
	PROJECT_NAME := $(addprefix -p , $(join $(APP_NAME), _$(APP_ENV)))
	COMPOSE_PROJECT_NAME := $(APP_NAME)-$(APP_ENV)
else
$(error APP_ENV is not valid, valid values are dev, test, staging, prod)
endif
endif

VARIABLES := PROJECT_NAME=$(COMPOSE_PROJECT_NAME) DB_USERNAME=$(DB_USERNAME) DB_PASSWORD=$(DB_PASSWORD) DB_DATABASE=$(DB_DATABASE) DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_ROOT_PASSWORD=$(DB_ROOT_PASSWORD) DB_ROOT_USERNAME=$(DB_ROOT_USERNAME) TAG=$(VERSION)
PORTS := NGINX_PORT=$(NGINX_PORT) REDIS_PORT=$(REDIS_PORT) PHP_MY_ADMIN_PORT=$(PHP_MY_ADMIN_PORT) NPM_PORT=$(NPM_PORT) NPM_PORT_SSL=$(NPM_PORT_SSL) MAIL_PORT=$(MAIL_PORT) MAILHOG_PORT=$(MAILHOG_PORT) 
INTERACTIVE := $(shell [ -t 0 ] && echo 1)
ERROR_ONLY_FOR_HOST = @printf "\033[33mThis command for host machine\033[39m\n"
.DEFAULT_GOAL := help
ifneq ($(INTERACTIVE), 1)
	OPTION_T := -T
endif
ifeq ($(GITLAB_CI), 1)
	# Determine additional params for phpunit in order to generate coverage badge on GitLabCI side
	PHPUNIT_OPTIONS := --coverage-text --colors=never
endif

help: ## Shows available commands with description
	@echo "\033[34mList of available commands:\033[39m"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "[32m%-27s[0m %s\n", $$1, $$2}'

build: ## Build image for environments
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml build --progress=plain
else
	$(ERROR_ONLY_FOR_HOST)
endif
rebuild: ## Rebuild image for environments
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml build --no-cache --progress=plain
else
	$(ERROR_ONLY_FOR_HOST)
endif

build-dev: ## Build dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml -f docker-compose.dev.yml build --progress=plain
else
	$(ERROR_ONLY_FOR_HOST)
endif

rebuild-dev: ## Rebuild dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml -f docker-compose.dev.yml build --no-cache --progress=plain
else
	$(ERROR_ONLY_FOR_HOST)
endif


build-prod: ## Build prod environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.prod.yml build
else
	$(ERROR_ONLY_FOR_HOST)
endif

start: ## Start dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml -f docker-compose.prod.yml $(PROJECT_NAME) up -d
else
	$(ERROR_ONLY_FOR_HOST)
endif

start-dev: ## Start dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml -f docker-compose.dev.yml $(PROJECT_NAME) up -d
else
	$(ERROR_ONLY_FOR_HOST)
endif

stop: ## Stop dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml $(PROJECT_NAME) down
else
	$(ERROR_ONLY_FOR_HOST)
endif

down: ## Stop dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml $(PROJECT_NAME) down
else
	$(ERROR_ONLY_FOR_HOST)
endif

pause: ## Pause dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml $(PROJECT_NAME) pause
else
	$(ERROR_ONLY_FOR_HOST)
endif

unpause: ## Unpause dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose -f docker-compose.yml $(PROJECT_NAME) unpause
else
	$(ERROR_ONLY_FOR_HOST)
endif

restart: stop start ## Stop and start dev environment

ssh: ## Get bash inside laravel docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec $(PHP_USER) app /bin/sh
else
	$(ERROR_ONLY_FOR_HOST)
endif

ssh-root: ## Get bash as root user inside laravel docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec $(OPTION_T) app /bin/sh
else
	$(ERROR_ONLY_FOR_HOST)
endif

ssh-db: ## Get bash inside mysql docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec db bash
else
	$(ERROR_ONLY_FOR_HOST)
endif

node: ## Get bash inside node docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose run --rm --service-ports node $(COMMAND)
else
	$(ERROR_ONLY_FOR_HOST)
endif

node-dev: ## Run node dev server
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose run --rm --service-ports node yarn run dev $(OPTIONS)
else
	$(ERROR_ONLY_FOR_HOST)
endif

node-build: ## Build node app
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose run --rm --service-ports node yarn run build
else
	$(ERROR_ONLY_FOR_HOST)
endif

node-install: ## Install npm / yarn dependencies
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose run --rm --service-ports node yarn install $(OPTIONS)
else
	$(ERROR_ONLY_FOR_HOST)
endif

node-watch: ## Run hot reload for node app
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@B_ENV="dev" UID=$(UID) GID=$(GID) $(VARIABLES) $(PORTS) docker compose run --rm --service-ports node yarn run watch $(OPTIONS)
else
	$(ERROR_ONLY_FOR_HOST)
endif

exec:
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@$$cmd
else
	@UID=$(HOST_UID) GID=$(HOST_GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) app $$cmd
endif

exec-root:
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@$$cmd
else
	@UID=$(HOST_UID) GID=$(HOST_GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec $(OPTION_T) app $$cmd
endif

exec-bash:
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@bash -c "$(cmd)"
else
	@UID=$(HOST_UID) GID=$(HOST_GID) $(VARIABLES) $(PORTS) docker compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) app bash -c "$(cmd)"
endif

env-dev: #Copy .env.dev to .env
	@cp .env.dev .env && echo "Copied .env.dev to .env, successfully!"

wait-for-db:
	@make exec cmd="php artisan db:wait"

composer-install-no-dev: ## Installs composer no-dev dependencies
	@make exec cmd="composer install --optimize-autoloader --no-dev"

composer-install: ## Installs composer dependencies
	@make exec-root cmd="composer install --optimize-autoloader"

composer-update: ## Updates composer dependencies
	@make exec cmd="composer update"

key-generate: ## Sets the phplication key
	@make exec cmd="php artisan key:generate"

composer-require:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer require $(PACKAGE)"

composer-require-dev:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer require --dev $(PACKAGE)"

composer-remove:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer remove $(PACKAGE)"

composer-remove-dev:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer remove --dev $(PACKAGE)"

serve: ## Runs the phplication
	@make exec cmd="php artisan serve"

info: ## Shows Php and Laravel version
	@make exec cmd="php artisan --version"
	@make exec cmd="php artisan env"
	@make exec cmd="php --version"

migrate-fresh: ## Drops databases and runs all migrations for the main/test databases
	@make exec cmd="php artisan migrate:fresh"

migrate-no-test: ## Runs all migrations for main database
	@make exec cmd="php artisan migrate --force"

migrate: ## Runs all migrations for main/test databases
	@make exec cmd="php artisan migrate"

seed: ## Runs all seeds for test database
	@make exec cmd="php artisan db:seed --force"

composer-normalize: ## Normalizes composer.json file content
	@make exec cmd="composer normalize"

composer-validate: ## Validates composer.json file content
	@make exec cmd="composer validate --no-check-version"

composer-require-checker: ## Checks the defined dependencies against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-require-checker"

composer-unused: ## Shows unused packages by scanning and comparing package namespaces against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-unused"