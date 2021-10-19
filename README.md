# Cloud Orchestrator を docker-compose で起動するやつ

自分用

## 起動方法

```
$ git clone https://paleog.intellil.ink/onotm/cloud-docker-compose.git
$ cd cloud-docker-compose
$ vi ./docker-compose.yml  # 変数とかを変更
$ docker-compose up -d --build
```

初回起動時は Drupal と Cloud Orchestrator のインストール処理が走るので、 `docker-compose up -d --build` が成功した後3分くらい待ってからアクセスすること。


そのほかの操作

```
$ docker-compose start  # 起動
$ docker-compose stop   # 停止
$ docker-compose rm     # 削除
$ docker-compose exec cloudorchestrator bash   # Cloud Orchestrator のコンテナにログインする
```

## そのほか

***composer、それは実行するたびに実行結果が変わる魔法のパッケージマネージャ。***

<!--
あとで使うかもしれないのでメモ。

```
$ # プライベートディレクトリの設定
$ echo "\$settings['file_private_path'] = __DIR__ . '/files/private';"  \
    >> /opt/drupal/web/sites/default/settings.php

$ # エラーログをブラウザ表示
$ echo "\$config['system.logging']['error_level'] = 'verbose';"  \
    >> /opt/drupal/web/sites/default/settings.php
```
-->
