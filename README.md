# Wordpress Docker Stack

This stack allows you to run a Wordpress application in a Docker container.
It integrates [Roots](https://roots.io/) components to provide a complete solution for Wordpress development in a modern
way.

## Features

- Web application container (Apache + PHP).
- Database container (MariaDB).
- Database manager container (Adminer).
- Reverse proxy container (Traefik).
- Mailcatcher container (Mailpit).
- Publicly exposition of web local (Ngrok).
- [Roots/Bedrock](https://roots.io/bedrock/) Wordpress boilerplate.
- [Roots/Sage](https://roots.io/sage/) Wordpress theme.
- A complete [Makefile](/Makefile) for easy setup and run commands.

## Quick start

```shell
make init
```

if you run another instance before a first `init` you should run:

```shell
make reinit
```

> Be careful `reinit` action will delete database and theme files.

## Configuration

### Print configuration variables list

```shell
make config
```

### Print one configuration variable

```shell
make config-get var=NAME_OF_VARIABLE
```

### Available configuration variables

#### PROJECT_NAME

Name of the project.

#### PROJECT_ROOT_DIR

Root directory of the project.

#### APP_ROOT_DIR

Root directory of the web application.

#### THEME_NAME

Name of the Wordpress theme.

#### THEME_ROOT_DIR

Root directory of the Wordpress theme.

#### SERVE_BASE_HOST

Local domain used for the reverse proxy.

#### SERVE_WEB_PROXY

Hostname of the application website (Wordpress).

#### SERVE_DB_PROXY

Hostname of the database manager webUI (Adminer).

#### SERVE_MAIL_PROXY

Hostname of the mail server webUI (Mailpit).

#### SERVE_TRAEFIK_PROXY

Hostname of the reverse proxy webUI (Traefik).

### User variables (advanced usage)

Copy `docker/conf/.user.env.sample` to `./.user.env` and custom with your own values.

#### LOCAL_UID

User ID of the host user.

#### LOCAL_USERNAME

Username of the host user.

#### LOCAL_GID

Group ID of the host user.

#### LOCAL_GROUPNAME

Group name of the host user.

#### LOCAL_HOME

Home directory of the host user.

#### LOCAL_DOCKER_IP

IP address of the Docker host.

#### DB_ENGINE

Database engine.

#### DB_PORT

Database port.
#### DB_CHARSET

Database charset.

#### DB_SERVER_VERSION

Database server version.

#### DB_ROOT_PASSWORD

Database root password.

#### DB_NAME

Database name.

#### DB_USER

Database user.

#### DB_PASSWORD

Database password.

#### DB_PREFIX

Database prefix.

#### ADMIN_USER

Admin username.

#### ADMIN_PASSWORD

Admin password.

#### ADMIN_EMAIL

Admin email.

#### HOME_URL

Home URL.

#### SITE_TITLE

Site title.

#### NGROK_AUTHTOKEN

Authtoken to publicly expose the web local with [ngrok](https://ngrok.com/).

#### EXPOSE_SHARE_TOKEN

Share token to publicly expose the web local with [expose](https://expose.dev/)

### Customize configuration

#### Easy way

```shell
make config-set VAR=NAME_OF_VARIABLE VAL=VALUE_OF_VARIABLE
```

#### Advanced way

Copy `./docker/conf/.config.sample.env` to `./.config.env` and customize it with your own set of values.

