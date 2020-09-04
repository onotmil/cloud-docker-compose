# 構築

## Requirements

* Docker
* docker-compose
* git

## docker-composeを用いた構築

起動

```
$ docker image pull drupal:9.0.5-apache-buster
$ docker image pull mariadb:10.5.5-focal
$ docker image pull centos:centos7
$ git clone https://gogs.prv.onotm.net/onotmil/cloud-docker-compose.git
$ cd cloud-docker-compose
$ docker-compose up -d --build
```

起動、停止

```
$ docker-compose start
$ docker-compose stop
```


## Drupalインストール

ブラウザからDrupalにアクセスしてDrupalをインストールする。

1. 言語設定: 日本語
2. インストールプロフィール: 標準
3. データベースの構成
  - タイプ: MySQL
  - DB名: drupal
  - username: root
  - password: postgres
  - host: cloud-mariadb
  - port: 3306
4. 環境設定
  - サイト名: cloud-onotm
  - email: onotm@intellilink.co.jp
  - username: onotm
  - 国: 日本
  - timezone: Tokyo
  - [x] 自動的にアップデートを確認
  - [ ] メール通知を受け取る

## Drupalをインストールした後に必要な設定

Drupalコンテナにログイン

```
docker container exec -it cloud-drupal bash
```

settings.phpに設定追加。コンテナ内で実行すること

```
$ # プライベートディレクトリの設定
$ echo "\$settings['file_private_path'] = __DIR__ . '/files/private';"  \
    >> /opt/drupal/web/sites/default/settings.php

$ # エラーログをブラウザ表示
$ echo "\$config['system.logging']['error_level'] = 'verbose';"  \
    >> /opt/drupal/web/sites/default/settings.php
```

画面から設定。

* Bootstrap for Cloud をインストールしてデフォルトに設定する。
  - [テーマ | onotm-cloud](http://workstation.onotm/admin/appearance)
* 必要なモジュールをインストールする。
  - [拡張 | onotm-cloud](http://workstation.onotm/admin/modules)
  - 有効にする順序に注意
    1. Address
    2. geofield, GEOCODINGの全て
    3. CLOUDの全て, CLOUD SERVICE PROVIDERSの全て


## メンテ用

### Drupalコンテナへのログイン

```
$ docker container exec -it cloud-drupal bash
```

### MariaDBへのログイン

クライアントのインストール

```
$ yum install -y mariadb
```

ホスト側にログイン設定を入れておく。`~/.my.cnf`

```
[client]
host=127.0.0.1
port=3306
user=root
password=postgres
```

ログイン

```
$ mysql --database=drupal
```


## misc

### cloud-drupal 単体での起動方法

```
$ docker image pull drupal:9.0.5-apache-buster
```

Dockerfileは `Dockerfile`。
docker build

```
$ docker image build -t cloud-drupal .
```

run

```
$ docker container run --name cloud-drupal  \
                       --restart unless-stopped -p 80:80 -d cloud-drupal
```


### cloud-mariadb 単体での起動方法

```
$ docker image pull mariadb:10.5.5-focal
```

run

```
$ docker container run --name cloud-mariadb -e MYSQL_ROOT_PASSWORD=postgres  \
                       --restart unless-stopped -p 3306:3306 -d mariadb:10.5.5-focal
$ mysql --execute='CREATE DATABASE drupal;'
```
