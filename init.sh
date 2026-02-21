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
#   3) APP_KEY 生成 (openssl を使用)
#
# -------------------------------------------------------------
set -euo pipefail

COMPOSER_VERSION="2.9.3"
IMAGE="composer/composer:${COMPOSER_VERSION}"
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
  # .env に APP_KEY が設定済みかチェック
  if grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    echo "[✔] APP_KEY already set – skipping"
    return
  fi
  echo "[⋯] Generating APP_KEY"
  APP_KEY="base64:$(openssl rand -base64 32)"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^APP_KEY=.*/APP_KEY=${APP_KEY}/" .env
  else
    sed -i "s/^APP_KEY=.*/APP_KEY=${APP_KEY}/" .env
  fi
  echo "[✔] APP_KEY generated"
}

main() {
  copy_env
  composer_install
  generate_key
  echo "🎉 Setup finished! Now you can run './vendor/bin/sail up -d' to start developing."
}

main "$@"
