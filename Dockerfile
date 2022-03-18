# Ref: https://git.drupalcode.org/project/cloud/-/blob/4.x/cfn/docker/Dockerfile
# Cloud Orchestrator Dockerfile
FROM php:7.4-apache-buster

RUN set -eux; \
    \
    if command -v a2enmod; then \
      a2enmod rewrite; \
    fi; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      libfreetype6-dev \
      libjpeg-dev \
      libpng-dev \
      libpq-dev \
      libzip-dev \
      libmemcached-dev \
      zlibc \
      zlib1g \
      git \
      zip \
      unzip \
      mariadb-client \
      cron \
    ; \
    \
    docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg \
    ; \
    \
    docker-php-ext-configure zip; \

    docker-php-ext-install -j "$(nproc)" \
      gd \
      opcache \
      pdo_mysql \
      pdo_pgsql \
      zip \
    ; \

    # Install Memcached
    git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
      && cd /usr/src/php/ext/memcached \
      && docker-php-ext-configure memcached \
      && docker-php-ext-install memcached; \

    curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer global require; \
    \

    # Install Drush
    git clone https://github.com/drush-ops/drush.git /usr/local/src/drush; \

    cd /usr/local/src/drush && git checkout 10.x; \
    ln -s /usr/local/src/drush/drush /usr/local/bin/drush; \
    composer install

# Cloud Orchestrator php configurations
RUN { \
    echo 'memory_limit = -1'; \
    echo 'max_execution_time = 600'; \
} > /usr/local/etc/php/conf.d/extras.ini

RUN { \
    echo '<VirtualHost *:80>'; \
    echo '  DocumentRoot /var/www/cloud_orchestrator/docroot'; \
    echo '  <Directory />'; \
    echo '    Options FollowSymLinks'; \
    echo '    AllowOverride None'; \
    echo '  </Directory>'; \
    echo '  <Directory /var/www/cloud_orchestrator/docroot>'; \
    echo '    Options FollowSymLinks MultiViews'; \
    echo '    AllowOverride All'; \
    echo '    order allow,deny'; \
    echo '    allow from all'; \
    echo '   </Directory>'; \
    echo '  ErrorLog /var/log/apache2/error.log'; \
    echo '  LogLevel warn'; \
    echo '  CustomLog /var/log/apache2/access.log combined'; \
    echo '</VirtualHost>'; \
} > /etc/apache2/sites-available/cloud_orchestrator.conf

RUN set -eux; \
  \
    # Unlink default apache configurations
    a2dissite 000-default; \
    a2dissite default-ssl.conf; \
    a2ensite cloud_orchestrator

RUN git config --global url."https://github.com/".insteadOf git@github.com: &&  \
    git config --global url."https://".insteadOf git://

ARG CLOUD_VERTION
RUN cd /var/www &&  \
    composer create-project  \
      docomoinnovations/cloud_orchestrator:${CLOUD_VERTION}  \
      cloud_orchestrator &&  \
    mkdir -p /var/files/drupal &&  \
    chown -R www-data:www-data /var/files/drupal &&  \
    chmod -R u+w /var/files/drupal

RUN cd /var/www/cloud_orchestrator &&  \
    composer -vvv require squizlabs/php_codesniffer drupal/coder &&  \
    echo 'export PATH="${PATH}:/var/www/cloud_orchestrator/vendor/bin"' >> /root/.bashrc

EXPOSE 80
WORKDIR /var/www/cloud_orchestrator

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

VOLUME /volume

RUN apt install -y less nano openssh-client jq;  \
    # curl -fsSL https://deb.nodesource.com/setup_16.x | bash -;  \
    # apt install -y nodejs;  \
    # npm install --global yarn;  \
    echo 'alias ll="ls -lah"' >> /root/.bashrc

CMD ["/entrypoint.sh"]
