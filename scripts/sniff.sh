#!/bin/bash

set -e

docker-compose run --entrypoint ./docker/run-entrypoint.sh -w /taller/app --rm app \
  ./bin/phpcs --extensions=php ./web/modules/custom

docker-compose run --entrypoint ./docker/run-entrypoint.sh -w /taller/app --rm app \
  ./bin/phpcs --extensions=php ./web/modules/sandbox
