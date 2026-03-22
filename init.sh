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
#   3) Sail コンテナ起動
#   4) composer run setup（key生成・マイグレーション・npm install/build）
#
# -------------------------------------------------------------
set -euo pipefail

COMPOSER_VERSION="2.9.5"
IMAGE="composer/composer:${COMPOSER_VERSION}"
CONTAINER_DIR="/var/www/html" # Sail の WORKDIR と合わせる

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

sail_up() {
  echo "[⋯] Starting Sail containers"
  ./vendor/bin/sail up -d
  echo "[✔] Sail containers started"
}

run_setup() {
  echo "[⋯] Running composer run setup via Sail"
  ./vendor/bin/sail composer run setup
  echo "[✔] Application setup completed"
}

sail_down() {
  echo "[⋯] Stopping Sail containers"
  ./vendor/bin/sail down
  echo "[✔] Sail containers stopped"
}

main() {
  copy_env
  composer_install
  sail_up
  run_setup
  sail_down
  echo "🎉 Setup finished! Run './vendor/bin/sail up' to start developing."
}

main "$@"
