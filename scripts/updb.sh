#!/bin/bash
if ! [[ -v CO_DIR ]]; then
  echo 'ERROR: Environment variable `CO_DIR` is not set' >> /dev/stderr
  exit 1
fi

cd ${CO_DIR}
drush -y cr
drush -y updb
