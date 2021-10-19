# 構築

## Requirements

* Docker
* docker-compose
* git

## docker-composeを用いた構築

起動

```
$ git clone https://paleog.intellil.ink/onotm/cloud-docker-compose.git
$ cd cloud-docker-compose
$ vi ./docker-compose.yml  # 変数とかを変更
$ docker-compose up -d --build
```

そのほかの操作

```
$ docker-compose start  # 起動
$ docker-compose stop   # 停止
$ docker-compose rm     # 削除
$ docker-compose exec cloudorchestrator bash   # Cloud Orchestrator のコンテナにログインする
```


## Drupalをインストールした後に必要な設定

Drupalコンテナにログイン

```
docker container exec -it cloud-drupal bash
```

settings.phpに設定追加。コンテナ内で実行すること


<!--
```
$ # プライベートディレクトリの設定
$ echo "\$settings['file_private_path'] = __DIR__ . '/files/private';"  \
    >> /opt/drupal/web/sites/default/settings.php

$ # エラーログをブラウザ表示
$ echo "\$config['system.logging']['error_level'] = 'verbose';"  \
    >> /opt/drupal/web/sites/default/settings.php
```
-->
