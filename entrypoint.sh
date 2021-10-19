#!/bin/bash

PROJECTROOT=/var/www/cloud_orchestrator
DOCROOT=${PROJECTROOT}/docroot

cd ${PROJECTROOT}

if ! [ -f ${DOCROOT}/sites/default/settings.php ]
then
  cp ${DOCROOT}/sites/default/default.settings.php  \
     ${DOCROOT}/sites/default/settings.php

  {
    echo "\$settings['file_private_path'] = '/var/files/drupal';"
    echo "\$databases['default']['default'] = array ("
    echo "  'database' => '${DatabaseName}',"
    echo "  'username' => '${MySQLUserName}',"
    echo "  'password' => '${MySQLPassword}',"
    echo "  'prefix' => '',"
    echo "  'host' => 'mariadb',"
    echo "  'port' => '3306',"
    echo "  'namespace' => 'Drupal\\\\Core\\\\Database\\\\Driver\\\\mysql',"
    echo "  'driver' => 'mysql',"
    echo ");"
  } >> ${DOCROOT}/sites/default/settings.php

  mkdir -p ${PROJECTROOT}/config/sync
  chown -R www-data:www-data ${PROJECTROOT}/config/sync
  chmod -R g+w ${PROJECTROOT}/config/sync

  sleep 20
  cd ${PROJECTROOT}
  drush si -y  \
    --db-url=mysql://${MySQLUserName}:${MySQLPassword}@mariadb:3306/${DatabaseName}  \
    --account-name=${DrupalUserName}  \
    --account-pass=${DrupalPassword}  \
    --site-name="Cloud Orchestrator"  \
    --account-mail=${DrupalEmail}  \
    cloud_orchestrator

  {
    echo "*/5 * * * * www-data cd /var/www/cloud_orchestrator && /usr/local/bin/drush cron > /dev/null 2>&1"
  } | crontab -

  # Switch to Claro Admin
  drush then -y claro
  drush cset -y system.theme admin claro

  # Setup Memcache module
  composer require drupal/memcache drupal/queue_ui
  drush en -y memcache memcache_admin
  drush cr

  {
    echo "\$settings['memcache']['servers'] = ['memcached:11211' => 'default'];"
    echo "\$settings['memcache']['bins'] = ['default' => 'default'];"
    echo "\$settings['memcache']['key_prefix'] = '';"
    echo "\$settings['cache']['default'] = 'cache.backend.memcache';"
  } >> ${DOCROOT}/sites/default/settings.php

  chown -R www-data:www-data ${PROJECTROOT}
  chmod -R g+w ${PROJECTROOT}
fi


apache2-foreground
