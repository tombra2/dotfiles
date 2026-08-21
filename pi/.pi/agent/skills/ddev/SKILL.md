---
name: ddev
description: REQUIRED for software-development work that runs project runtimes, dependency managers, framework CLIs, databases, web servers, workers, tests, linters, formatters, analyzers, migrations, fixtures, or build commands. Always use DDEV instead of host runtimes or direct Docker Compose. Triggers for PHP, Composer, Symfony, Laravel, Drupal, WordPress, Node, npm, databases, PHPUnit, tests, quality checks, console commands, local project setup, and starting or inspecting development services.
compatibility: Requires DDEV and Docker.
---

# Always use DDEV

Use DDEV as the runtime for every development project. Do not run project runtimes or services directly on the host.

## Before running project commands

1. Find the project root.
2. Check for `.ddev/config.yaml`.
3. If it exists, inspect it and run `ddev describe` to check the project status.
4. If the project is stopped, run `ddev start`.
5. Run subsequent commands from the project root.

If `.ddev/config.yaml` is missing, do not fall back to host runtimes or Docker Compose. Tell the user that the project has no DDEV configuration and ask before initializing one with `ddev config`.

## Command rules

Run project runtime commands inside the DDEV web container with `ddev exec`:

```bash
ddev exec php bin/console cache:clear
ddev exec composer install
ddev exec vendor/bin/phpunit
ddev exec npm install
ddev exec npm test
```

This applies to:

- PHP, Composer, Symfony Console, Artisan, Drush, and WP-CLI
- Node, npm, pnpm, Yarn, and frontend build tools
- PHPUnit, Pest, Behat, linters, formatters, static analyzers, and code generators
- migrations, fixtures, queues, workers, schedulers, and application scripts

Prefer DDEV's database commands where suitable:

```bash
ddev mysql
ddev import-db --file=dump.sql.gz
ddev export-db --file=dump.sql.gz
ddev describe
```

Use service hostnames and credentials from DDEV configuration. Typical in-container database values are host `db`, port `3306`, database `db`, username `db`, and password `db`, but inspect the project configuration instead of assuming them.

## Allowed host operations

File inspection and editing may run on the host because the project directory is mounted into DDEV. Git and basic filesystem commands may also run on the host:

```bash
git status
rg "pattern" src
find . -name '*.php'
```

Do not use host PHP, Composer, Node, databases, or project-specific executables from `vendor/bin` or `node_modules/.bin`.

## Exceptions

Use a host runtime only when the user explicitly requests it after being told that the normal workflow uses DDEV. Use direct `docker` commands only to diagnose DDEV or Docker itself. Do not use `docker compose up` as a substitute for `ddev start`.

When reporting verification commands, show the DDEV form so the user can repeat them.
