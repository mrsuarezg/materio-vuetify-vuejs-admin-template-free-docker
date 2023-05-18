# SPA Laravel - Vue 2__Materio Vuetify Vue.js Admin Template Free Docker
This is a free admin template based on Vuetify and Vue.js with a clean, new design inspired by Google's Material Design. It's free and Open Source under the MIT license.
Use this tecnologies:
* Vue 2.7.14
* Vuetify 2
* Laravel 8

## Requirements
* Docker version 18.06 or later
* Docker compose version 1.22 or later
* An editor or IDE
* WSL2 (For Windows 10 or 11)

Note: OS recommendation - Linux Ubuntu based.

---

## Components
1. Nginx 1.24.0
2. PHP 8.0.28
3. MariaDB 10.6
4. Laravel 8.54
5. Node 20.2.0
    5.1 npm 9.6.6
    5.2 yarn 1.22.19

---

## Setting up DEV environment
1.You can clone this repository or download it as a zip file.

```bash
git clone git@github.com:mrsuarezg/materio-vuetify-vuejs-admin-template-free-docker.git
```

2.Open terminal and go to the project directory.

```bash
cd materio-vuetify-vuejs-admin-template-free-docker
```

3.Build, start and install the docker images from your terminal:
```bash
make build "(this command obbligatory for first time or if you change docker-compose.yml, and config files in docker folder)"
make build-dev "for dev environment"
make start-dev "for dev environment"
make composer-install
make node-install "By default yarn is used, if you want to use npm, edit Makefile and change yarn to npm"
make env-dev
```

4.Need open new terminal and go to the project directory.

```bash
make node-dev "This command is necessary for dev environment, it will run yarn run watch command in docker container"
```

5.Set key for application:
```bash
make key-generate
```

6.Make sure that you have installed migrations/seeds:
```bash
make migrate
make seed
```

7.Check and open in your browser next url: [http://localhost](http://localhost).

Note 1: If you want to change default docker configurations (NGINX_PORT, etc...) - open `.env.dev` file, edit necessary environment variable value and stop, rebuild, start docker containers.

Note 2: Remember if you change NGINX_PORT in `.env.dev`, the url will be: [http://localhost:NGINX_PORT](http://localhost:NGINX_PORT).
---

## Install/Uninstall dependencies from NPM, Composer, etc...
For installing/uninstalling dependencies from Node (NPM, YARN) or Composer, you two options:
1. Install dependencies from local shell you need to get shell access inside container:
```bash
make ssh-root
composer require laravel/ui // for example
```
Note: Please use `exit` command in order to return from container's shell to local shell.

2. Install dependencies from local shell without getting shell access inside container:
```bash
make node-install OPTIONS="--save-dev @babel/core @babel/preset-env" // for example
or
make node COMMAND="npm install --save-dev @babel/core @babel/preset-env || node -v || npm -v || yarn -v" // for example

make composer-require PACKAGE="laravel/ui" // for example
make composer-require-dev PACKAGE="laravel/ui" // for example
make composer-remove PACKAGE="laravel/ui" // for example
make composer-remove-dev PACKAGE="laravel/ui" // for example
```
## Guidelines
* make help - show all available commands
* [Commands](docs/commands.md)
* [Materio](docs/materio.md)

## License
[The MIT License (MIT)](LICENSE)