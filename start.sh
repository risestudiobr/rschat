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

install_front_if_needed() {
  # Só o WEB precisa compilar assets (vite). Worker não precisa de frontend deps.
  if [ "$ROLE" != "web" ]; then
    return 0
  fi

  # Garante pnpm
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "Instalando pnpm..."
    npm i -g pnpm@9
  fi

  if [ -f package.json ]; then
    echo "Instalando dependências frontend..."
    if [ -f pnpm-lock.yaml ]; then
      pnpm install --frozen-lockfile || pnpm install
    else
      pnpm install
    fi
  fi
}

case "$ROLE" in
  web)
    wait_for_db
    bundle exec rails db:chatwoot_prepare
    bundle exec rails db:migrate

    install_front_if_needed

    bundle exec rails assets:precompile
    echo "Iniciando WEB na porta ${PORT}..."
    exec bundle exec rails s -b 0.0.0.0 -p "$PORT"
    ;;

  worker)
    wait_for_db
    echo "Iniciando WORKER (Sidekiq)..."
    exec bundle exec sidekiq -C config/sidekiq.yml
    ;;

  combined)
    wait_for_db
    bundle exec rails db:chatwoot_prepare
    bundle exec rails db:migrate

    install_front_if_needed

    bundle exec rails assets:precompile

    echo "Iniciando Web + Worker com multirun..."
    exec multirun \
      "bundle exec sidekiq -C config/sidekiq.yml" \
      "bundle exec rails s -b 0.0.0.0 -p ${PORT:-3000}"
    ;;
  *)
    echo "ERRO: ROLE inválido: '$ROLE'. Use 'web' ou 'worker'."
    exit 1
    ;;
esac
