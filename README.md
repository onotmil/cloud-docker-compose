# Cloud Orchestrator を docker-compose で起動するやつ

自分用

## 起動方法

```
$ git clone https://paleog.intellil.ink/onotm/cloud-docker-compose.git
$ cd cloud-docker-compose
$ vi ./docker-compose.yml  # 変数とかを変更
$ mkdir ./volume  # このディレクトリがコンテナにバインドされ、中にcloudモジュールのリポジトリがcloneされる

$ PROJECT_NAME=cloudorchestrator
$ docker-compose --project-name ${PROJECT_NAME} up --build --detach
```

初回起動時は Drupal と Cloud Orchestrator のインストール処理が走るので、 `docker-compose up -d --build` が成功した後5分くらい待ってからアクセスすること。

コピペ用

```
$ # 起動
$ docker-compose --project-name ${PROJECT_NAME} start

$ # 停止
$ docker-compose --project-name ${PROJECT_NAME} stop

$ # 削除
$ docker-compose --project-name ${PROJECT_NAME} down --volumes --remove-orphans
$ rm -rf ./volume/*

$ # ログ
$ docker-compose --project-name ${PROJECT_NAME} logs --follow cloudorchestrator

$ # Cloud Orchestrator のコンテナにログインする
$ docker-compose --project-name ${PROJECT_NAME} exec cloudorchestrator bash
```

## そのほか

***composer、それは実行するたびに結果が変わる魔法のパッケージマネージャ。***

<!--
あとで使うかもしれないのでメモ。

```
$ # プライベートディレクトリの設定
$ echo "\$settings['file_private_path'] = __DIR__ . '/files/private';"  \
    >> /opt/drupal/web/sites/default/settings.php
```
-->
