#!/bin/sh
set -e

echo "Aguardando banco de dados..."
while ! pg_isready -h ${PGHOST} -p ${PGPORT}; do sleep 0.25; done;
echo "Banco disponível."

exec bundle exec sidekiq -C config/sidekiq.yml
