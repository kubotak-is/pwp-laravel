# pwp-laravel

プロフェッショナルWebプログラミング Laravel改訂版 学習用リポジトリ

## 始め方

### ダウンロード

[https://github.com/kubotak-is/pwp-laravel/archive/refs/heads/main.zip](https://github.com/kubotak-is/pwp-laravel/archive/refs/heads/main.zip)

### Docker の導入

このリポジトリはLaravel Sailをベースとしていますので、Dockerの導入が必要です。

Windows、Macともに以下のURLより事前に導入してください。

[https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

### 初回起動

初回起動用のシェルスクリプトを用意しているので、実行権限を付与して実行してください。

```sh
# 実行権限を付与する
chmod +x init.sh
```

```sh
# 実行
./init.sh
```

この初回起動用のシェルスクリプトにより、Laravelが提供するDocker向けの開発環境のLaravel Sailが導入されます。

### Windows の場合

実行した際にDockerへの権限がないというエラーになった場合は一度WSLをシャットダウンして再度ログインをしてお試しください。

```sh
# UbuntuではなくPowerShell側で以下を実行
wsl --shutdown
```

また、Windowsをお使いの方は[Visual Studio Code](https://code.visualstudio.com)というエディタをおすすめします。

Visual Studio Codeの[WSLプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)をインストールして有効化し、Ubuntuのターミナルにて以下のように入力することでVisual Studio Codeが起動し、実行したディレクトリのファイルを編集することができます。

```sh
code .
```

ファイルの追加等もVisual Studio Code上から行えます。また、以下のプラグインの導入もすると、より便利に使えます。

- [PHP Intelephense](https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client)
- [Laravel](https://marketplace.visualstudio.com/items?itemName=laravel.vscode-laravel)