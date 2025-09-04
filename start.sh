#!/bin/sh
set -e

#web - worker - combined
ROLE="${ROLE:-web}"
PORT="${PORT:-3000}"

wait_for_db() {
  echo "Aguardando banco de dados..."
  while ! pg_isready -h ${PGHOST} -p ${PGPORT}; do sleep 0.25; done;
  echo "Banco disponível."
}

case "$ROLE" in
  web)
    wait_for_db
    bundle exec rails db:chatwoot_prepare
    bundle exec rails db:migrate

    echo "Iniciando WEB na porta ${PORT}..."
    exec bundle exec rails s -b 0.0.0.0 -p "$PORT"
    ;;

  worker)
    wait_for_db
    echo "Iniciando WORKER (Sidekiq)..."
    exec bundle exec sidekiq -C config/sidekiq.yml
    ;;
  *)
    echo "ERRO: ROLE inválido: '$ROLE'. Use 'web' ou 'worker'."
    exit 1
    ;;
esac
