#!/bin/bash

cd "${CO_DIR}"
if ! [[ -e "${SETTINGS_FILE}" ]]; then
  while true; do
    if mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e 'show databases;' > /dev/null; then
      break
    fi
    echo 'Waiting for the database to respond...'
    sleep 10
  done

  mkdir -p "${FILES_DIR}"
  cp "${DEFAULT_SETTINGS_FILE}" "${SETTINGS_FILE}"
  chown -R www-data:www-data "${SETTINGS_FILE}"
  chmod -R g+w "${SETTINGS_FILE}"
  chown -R www-data:www-data "${FILES_DIR}"
  chmod -R g+w "${FILES_DIR}"

  tee -a "${SETTINGS_FILE}" > /dev/null <<EOF
\$settings['file_private_path'] = '${PRIVATE_FILE_DIR}';
\$settings['config_sync_directory'] = '${CONFIG_DIR}';
EOF

  # Install Cloud Orchestrator using Drush.
  drush si -y \
    --db-url="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}" \
    --account-name="${DRUPAL_USER}" \
    --account-pass="${DRUPAL_PASSWORD}" \
    --site-name='Cloud Orchestrator' \
    --account-mail="${DRUPAL_EMAIL}" \
    cloud_orchestrator \
    # cloud_orchestrator_module_configure_form.cloud_service_providers.terraform=terraform \
    # cloud_orchestrator_module_configure_form.cloud_service_providers.openstack=openstack \
    # cloud_orchestrator_module_configure_form.cloud_service_providers.vmware=vmware

  chown -R www-data:www-data "${CO_DIR}/files"
  chown -R www-data:www-data "${CO_DIR}/docroot/sites/default/files"

  # Set timezone.
  drush -y config:set system.date timezone.default "${DRUPAL_TIMEZONE}"

  # Switch to Claro Admin.
  drush then -y claro
  drush cset -y system.theme admin claro

  drush en -y memcache memcache_admin

  tee -a "${SETTINGS_FILE}" > /dev/null <<EOF
\$settings['memcache']['servers'] = ['${MEMCACHED_HOST}:${MEMCACHED_PORT}' => 'default'];
\$settings['memcache']['bins'] = ['default' => 'default'];
\$settings['memcache']['key_prefix'] = '';
\$settings['cache']['default'] = 'cache.backend.memcache';
EOF

  DRUSH_QUEUE_RUN_SCRIPT="${CO_DIR}/docroot/modules/contrib/cloud/scripts/drush_queue_run.sh"
  chmod +x "${DRUSH_QUEUE_RUN_SCRIPT}"
  tee /etc/crontab > /dev/null <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=''

*/1 * * * * www-data cd '${CO_DIR}'; drush cron > /dev/null 2>&1
*/15 * * * * www-data cd '${CO_DIR}'; '${DRUSH_QUEUE_RUN_SCRIPT}' > /dev/null 2>&1
EOF

  mv "${CO_DIR}/docroot/modules/contrib/cloud/"*      "${CLOUD_VOLUME}"
  mv "${CO_DIR}/docroot/modules/contrib/cloud/".[!.]* "${CLOUD_VOLUME}"
  rm -rf "${CO_DIR}/docroot/modules/contrib/cloud"
  ln -s "${CLOUD_VOLUME}" "${CO_DIR}/docroot/modules/contrib/cloud"

  mv "${SETTINGS_FILE}" "${SETTINGS_VOLUME}/settings.php"
  ln -s "${SETTINGS_VOLUME}/settings.php" "${SETTINGS_FILE}"

  # ################################################  CLOUD_DASHBOARD  ########
  # https://git.drupalcode.org/project/cloud/-/blob/5.x/modules/cloud_dashboard/INSTALL.md
  # rm -rf ${DOCROOT}/modules/contrib/cloud_dashboard
  # ln -s ${VOLUME_ROOT}/cloud/modules/cloud_dashboard  \
  #       ${DOCROOT}/modules/contrib/cloud_dashboard
  #
  # cd ${DOCROOT}
  # drush en -y cloud_dashboard simple_oauth jsonapi

  # https://git.drupalcode.org/project/cloud/-/blob/5.x/modules/cloud_dashboard/BUILD.md
  # cd ${DOCROOT}/modules/contrib/cloud_dashboard/cloud_dashboard
  # yarn
  # bash ./build.sh
fi

drush -y cr
drush -y updb

cron
apache2-foreground
