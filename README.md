# Cloud Orchestrator を docker-compose で起動するやつ

自分用

## 起動方法

```
$ git clone https://paleog.intellil.ink/onotm/cloud-docker-compose.git
$ cd cloud-docker-compose
$ vi ./docker-compose.yml  # 変数とかを変更
$ rm -rf ./volumes/cloud ./volumes/settings  \
  && mkdir ./volumes/cloud ./volumes/settings

$ PROJECT_NAME=cloud-orchestrator
$ docker-compose --project-name ${PROJECT_NAME} up --build --detach
```

初回起動時は Drupal と Cloud Orchestrator のインストール処理が走るので、 `docker-compose up -d --build` が成功した後5分くらい待ってからアクセスすること。

デフォルトでは、 `./volumes/cloud` に cloud モジュールのディレクトリが、 `./volumes/settings` に配下に Drupal の設定ファイルを含むディレクトリがバインドされるので、これらのファイルを変更することでコンテナの中にも反映できる。

コピペ用

```
$ # 起動
$ docker-compose --project-name ${PROJECT_NAME} start

$ # 停止
$ docker-compose --project-name ${PROJECT_NAME} stop

$ # 削除
$ docker-compose --project-name ${PROJECT_NAME} down --volumes --remove-orphans
$ rm -rf ./volumes/*

$ # ログ
$ docker-compose --project-name ${PROJECT_NAME} logs --follow cloud-orchestrator

$ # Cloud Orchestrator のコンテナにログインする
$ docker-compose --project-name ${PROJECT_NAME} exec cloud-orchestrator bash
```

`phpcs` を実行する。 FIXME: 動作未確認。
パス部分は適宜変更すること。このまま走らせるとCloudモジュール全てのファイルを調べるのですごく時間がかかる。

```
$ docker-compose --project-name ${PROJECT_NAME} exec cloud-orchestrator bash
# phpcs  \
    --standard=DrupalPractice,Drupal  \
    --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md,yml  \
    /var/www/cloud_orchestrator/docroot/modules/contrib/cloud
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
