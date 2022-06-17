# Cloud Orchestrator を docker-compose で起動するための色々

自分用

## 起動方法

```
$ git clone https://github.com/onotmil/cloud-docker-compose.git
$ cd cloud-docker-compose
$ vi ./docker-compose.yml  # services.cloud-orchestrator.environment の変数を変更
$ rm -rf ./volumes/cloud ./volumes/settings  \
  && mkdir ./volumes/cloud ./volumes/settings

$ PROJECT_NAME=cloud-orchestrator
$ docker-compose --project-name ${PROJECT_NAME} up --build --detach
```

初回起動時は Drupal と Cloud Orchestrator のインストール処理が走るので、 `docker-compose up -d --build` が成功した後5分くらい待ってからアクセスすること。
起動中のログを見る方法は下のコマンド例を参照。

デフォルトでは、 `./volumes/cloud` に cloud モジュールのディレクトリが、 `./volumes/settings` に配下に Drupal の設定ファイルを含むディレクトリがバインドされるので、これらのファイルを変更することでコンテナの中にも反映できる。
`drush updb` が必要な場合は、コンテナの中にスクリプトを仕込んでいるのでそれを実行すると簡単。


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

$ # drush cr && drush updb を実行する
$ docker-compose --project-name ${PROJECT_NAME} exec cloud-orchestrator /scripts/updb.sh
```

`phpcs` を実行するなら。
パス部分は適宜変更すること。このまま走らせるとCloudモジュール全てのファイルを調べるのですごく時間がかかる。

```
$ docker-compose --project-name ${PROJECT_NAME} exec cloud-orchestrator bash
# phpcs  \
    --standard=DrupalPractice,Drupal  \
    --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md,yml  \
    /var/www/cloud_orchestrator/docroot/modules/contrib/cloud
```

コンテナを作り直さずにCloudモジュールを更新するなら。

```
$ cd volumes/cloud
$ git pull
$ docker-compose --project-name ${PROJECT_NAME} exec cloud-orchestrator /scripts/updb.sh
```

<!--
## そのほか

***composer、それは実行するたびに結果が変わる魔法のパッケージマネージャ。***
-->
