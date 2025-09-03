#!/bin/sh
set -e

echo "Aguardando banco de dados..."
while ! pg_isready -h ${PGHOST} -p ${PGPORT}; do sleep 0.25; done;
echo "Banco disponível."

bundle exec rails db:chatwoot_prepare
bundle exec rails db:migrate

bundle exec rails assets:precompile

exec bundle exec rails s -b 0.0.0.0 -p "${PORT:-3000}"
