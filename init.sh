#!/usr/bin/env bash
# init.sh – one-shot bootstrap script for Laravel Sail projects
# -------------------------------------------------------------
# 使い方:
#   chmod +x init.sh   # ← 1回だけ実行権限を付与
#   ./init.sh          # ← 初回セットアップ完了後は不要
#
# 処理内容:
#   1) .env.example → .env （存在しなければコピー）
#   2) Docker 経由で composer install --ignore-platform-reqs
#   3) php artisan key:generate  (Sail を使って APP_KEY 生成)
#
# -------------------------------------------------------------
set -euo pipefail

PHP_VERSION="8.4"
IMAGE="laravelsail/php${PHP_VERSION/./}-composer:latest"   # 例: laravelsail/php84-composer:latest
CONTAINER_DIR="/var/www/html"                               # Sail の WORKDIR と合わせる

copy_env() {
  if [ -f .env ]; then
    echo "[✔] .env already exists – skipping copy"
  elif [ -f .env.example ]; then
    cp .env.example .env && echo "[+] .env created from .env.example"
  else
    echo "[✖] .env.example not found – aborting" >&2
    exit 1
  fi
}

composer_install() {
  echo "[⋯] Running composer install via Docker (${IMAGE})"
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):${CONTAINER_DIR}" \
    -w "${CONTAINER_DIR}" \
    "${IMAGE}" \
    composer install --ignore-platform-reqs
  echo "[✔] composer install completed"
}

generate_key() {
  if [ ! -x ./vendor/bin/sail ]; then
    echo "[✖] vendor/bin/sail not found – did composer install succeed?" >&2
    exit 1
  fi
  echo "[⋯] Generating APP_KEY via Sail"
  ./vendor/bin/sail artisan key:generate --force
  echo "[✔] APP_KEY generated"
}

main() {
  copy_env
  composer_install
  generate_key
  echo "🎉 Setup finished! Now you can run './vendor/bin/sail up -d' to start developing."
}

main "$@"
