FROM docomoinnovations/cloud_orchestrator:5.x-dev

RUN apt install -y less nano openssh-client jq; \
    echo 'alias ll="ls -lah"' >> /root/.bashrc

ARG CLOUD_ORCHESTRATOR_VERSION=5.x-dev
ARG CLOUD_VOLUME='/cloud'
ARG SETTINGS_VOLUME='/settings'

ENV CLOUD_ORCHESTRATOR_VERSION="${CLOUD_ORCHESTRATOR_VERSION}"
ENV CLOUD_VOLUME="${CLOUD_VOLUME}"
ENV SETTINGS_VOLUME="${SETTINGS_VOLUME}"
ENV CO_DIR='/var/www/cloud_orchestrator'
ENV SETTINGS_FILE="${CO_DIR}/docroot/sites/default/settings.php"
ENV PRIVATE_FILE_DIR="${CO_DIR}/files/private"
ENV CONFIG_DIR="${CO_DIR}/files/config/sync"
ENV FILES_DIR="${CO_DIR}/docroot/sites/default/files"
ENV DEFAULT_SETTINGS_FILE="${CO_DIR}/docroot/sites/default/default.settings.php"

RUN rm -rf "${CO_DIR}/"*; \
    git config --global url.'https://github.com/'.insteadOf 'git@github.com:'; \
    git config --global url.'https://'.insteadOf 'git://'; \
    composer create-project "docomoinnovations/cloud_orchestrator:${CLOUD_ORCHESTRATOR_VERSION}" "${CO_DIR}"; \
    chown -R www-data:www-data "${CO_DIR}"; \
    echo 'export PATH="${PATH}:${CO_DIR}/vendor/bin"' >> /root/.bashrc

# Setup private directories.
RUN mkdir -p "${PRIVATE_FILE_DIR}"; \
    mkdir -p "${CONFIG_DIR}"; \
    chown -R www-data:www-data "${CO_DIR}/files"; \
    chmod -R g+w "${CO_DIR}/files"

# Set up a drush command.
RUN ln -s "${CO_DIR}/vendor/bin/drush" /usr/local/bin/

# Set up phpcs command.
RUN cd ${CO_DIR}; \
    composer require squizlabs/php_codesniffer drupal/coder

# RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -;  \
#     apt install -y nodejs;  \
#     npm install --global yarn;  \

VOLUME "${CLOUD_VOLUME}"
VOLUME "${SETTINGS_VOLUME}"

COPY scripts /scripts
RUN chmod 755 /scripts/*.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
CMD ["/entrypoint.sh"]
