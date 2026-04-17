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
#   5) シェル設定ファイルに 'sail' エイリアスを自動追加
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
  ./vendor/bin/sail up -d --wait
  echo "[✔] Sail containers started"
}

run_setup() {
  echo "[⋯] Running composer run setup via Sail"
  ./vendor/bin/sail composer run setup
  echo "[✔] Application setup completed"
}

setup_alias() {
  RC_FILE=""
  ALIAS_COMMAND="alias sail='bash vendor/bin/sail'"

  # ユーザーのログインシェルに応じて設定ファイルを決定
  if [[ "${SHELL:-}" == */zsh ]]; then
    RC_FILE="$HOME/.zshrc"
  elif [[ "${SHELL:-}" == */bash ]]; then
    RC_FILE="$HOME/.bashrc"
  fi

  # 設定ファイルが決定され、存在する場合に処理を行う
  if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
    # エイリアスがまだ設定されていない場合のみ追記
    if ! grep -qF "$ALIAS_COMMAND" "$RC_FILE"; then
      echo "" >> "$RC_FILE"
      echo "$ALIAS_COMMAND" >> "$RC_FILE"
      echo "[+] Added 'sail' alias to $RC_FILE."
      echo "    To apply it now, please run: source $RC_FILE"
    else
      echo "[✔] 'sail' alias already exists in $RC_FILE – skipping"
    fi
  fi
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
  setup_alias
  echo "🎉 Setup finished! Run 'sail up -d' to start developing."
}

main "$@"
