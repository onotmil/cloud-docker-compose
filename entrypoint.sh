#!/bin/bash

PROJECTROOT=/var/www/cloud_orchestrator
DOCROOT=${PROJECTROOT}/docroot

PRIVATEROOT=/var/files/drupal

cd ${PROJECTROOT}

if ! [ -f ${DOCROOT}/sites/default/settings.php ]
then
  cp ${DOCROOT}/sites/default/default.settings.php  \
     ${DOCROOT}/sites/default/settings.php

  {
    echo "\$settings['file_private_path'] = '${PRIVATEROOT}';"
    echo "\$databases['default']['default'] = array ("
    echo "  'database' => '${MYSQL_DATABASE}',"
    echo "  'username' => '${MYSQL_USER}',"
    echo "  'password' => '${MYSQL_PASSWORD}',"
    echo "  'prefix' => '',"
    echo "  'host' => 'mysql',"
    echo "  'port' => '3306',"
    echo "  'namespace' => 'Drupal\\\\Core\\\\Database\\\\Driver\\\\mysql',"
    echo "  'driver' => 'mysql',"
    echo ");"
  } >> ${DOCROOT}/sites/default/settings.php

  mkdir -p ${PROJECTROOT}/config/sync
  chown -R www-data:www-data ${PROJECTROOT}/config/sync
  chmod -R g+w ${PROJECTROOT}/config/sync

  mkdir -p ${PRIVATEROOT}
  chown -R www-data:www-data ${PRIVATEROOT}
  chmod -R 700 ${PRIVATEROOT}

  sleep 20
  cd ${PROJECTROOT}
  drush si -y  \
    --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}  \
    --account-name=${DRUPAL_USER}  \
    --account-pass=${DRUPAL_PASSWORD}  \
    --site-name="Cloud Orchestrator"  \
    --account-mail=${DRUPAL_EMAIL}  \
    cloud_orchestrator

  {
    echo "*/5 * * * * www-data cd /var/www/cloud_orchestrator && /usr/local/bin/drush cron > /dev/null 2>&1"
  } >> /etc/crontab

  # Switch to Claro Admin
  drush then -y claro
  drush cset -y system.theme admin claro

  # Setup Memcache module
  composer require drupal/memcache drupal/queue_ui
  drush en -y memcache memcache_admin

  {
    echo "\$settings['memcache']['servers'] = ['memcached:11211' => 'default'];"
    echo "\$settings['memcache']['bins'] = ['default' => 'default'];"
    echo "\$settings['memcache']['key_prefix'] = '';"
    echo "\$settings['cache']['default'] = 'cache.backend.memcache';"
    echo "\$config['system.logging']['error_level'] = 'verbose';"
  } >> ${DOCROOT}/sites/default/settings.php

  chown -R www-data:www-data ${PROJECTROOT}
  chmod -R g+w ${PROJECTROOT}
  drush -y cr
fi

cron
apache2-foreground
