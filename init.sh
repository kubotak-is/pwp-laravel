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
#   4) シェル設定ファイルに 'sail' エイリアスを自動追加
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
  echo "[⋯] Generating APP_KEY via Docker"
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):${CONTAINER_DIR}" \
    -w "${CONTAINER_DIR}" \
    "${IMAGE}" \
    php artisan key:generate --force
  echo "[✔] APP_KEY generated"
}

setup_alias() {
  RC_FILE=""
  ALIAS_COMMAND="alias sail='bash vendor/bin/sail'"

  # シェルに応じて設定ファイルを決定
  if [ -n "$ZSH_VERSION" ]; then
    RC_FILE="$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ]; then
    RC_FILE="$HOME/.bashrc"
  fi

  # zsh/bash 以外のシェルの場合、$SHELLから判定を試みる
  if [ -z "$RC_FILE" ] && [ -n "$SHELL" ]; then
    if [[ "$SHELL" == */zsh ]]; then
        RC_FILE="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        RC_FILE="$HOME/.bashrc"
    fi
  fi

  # 設定ファイルが決定され、存在する場合に処理を行う
  if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
    # エイリアスがまだ設定されていない場合のみ追記
    if ! grep -qF "$ALIAS_COMMAND" "$RC_FILE"; then
      echo "" >> "$RC_FILE" # 見た目を整えるための改行
      echo "$ALIAS_COMMAND" >> "$RC_FILE"
      echo "[+] Added 'sail' alias to $RC_FILE."
      echo "    To apply it now, please run: source $RC_FILE"
    fi
  fi
}

main() {
  copy_env
  composer_install
  generate_key
  setup_alias
  echo "🎉 Setup finished! Now you can run 'sail up -d' to start developing."
}

main "$@"
