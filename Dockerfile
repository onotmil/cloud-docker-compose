FROM drupal:9.0.5-apache-buster

WORKDIR /tmp
RUN echo "export EDITOR=nano"                     | tee --append /root/.bashrc
RUN echo "export HISTSIZE=10000"                  | tee --append /root/.bashrc
RUN echo "export HISTFILESIZE=1000000"            | tee --append /root/.bashrc
RUN echo "export HISTIGNORE='history:git status:git diff:git log:date:cal*:ls:ll:l:pwd'"  \
                                                  | tee --append /root/.bashrc
RUN echo "alias ll='ls -ahlp --color=auto'"       | tee --append /root/.bashrc
RUN echo "alias ls='ls --color=auto'"             | tee --append /root/.bashrc
RUN apt update && apt upgrade -y && apt autoremove -y
RUN apt install -y apt-utils awscli cron doxygen git graphviz iputils-ping  \
                   libaprutil1-ldap libcap2-bin libfreetype6-dev libjpeg-dev  \
                   libldap-2.4-2 libldap-common libldap2-dev libmemcached-dev  \
                   libpng-dev libpq-dev libzip-dev mariadb-client memcached  \
                   nano net-tools patchutils software-properties-common sqlite  \
                   sudo telnet tmux unzip vim wget zip zlib1g zlibc
RUN sed -i -e 's/memory_limit = .*/memory_limit = -1/' /usr/local/etc/php/php.ini-development
RUN ln -s /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN mkdir -p /opt/drupal/web/sites/default/files/private &&  \
    chown -R www-data:www-data /opt/drupal/web/sites/default/files &&  \
    chmod -R 755 /opt/drupal/web/sites/default/files

RUN composer config -g repos.packagist composer https://packagist.jp
RUN composer global -vvv require hirak/prestissimo

WORKDIR /opt/drupal
RUN composer config -vvv repositories.drupal composer https://packages.drupal.org/8
RUN composer global -vvv require drush/drush:dev-master
RUN composer -vvv require drupal/geocoder
RUN composer -vvv require drupal/geofield
RUN composer -vvv require drupal/address
# RUN composer -vvv require drupal/cloud
RUN composer -vvv require drupal/bootstrap_cloud
RUN mkdir -p /opt/drupal/web/modules/contrib &&  \
    chown -R www-data:www-data /opt/drupal/web/modules/contrib

WORKDIR /opt/drupal/web/modules/contrib
RUN git clone https://git.drupalcode.org/project/cloud.git &&  \
    chown -R www-data:www-data /opt/drupal/web/modules/contrib/cloud

WORKDIR /opt/drupal/web
RUN chown -R www-data:www-data /opt/drupal &&  \
    chmod -R 755 /opt/drupal/web/sites/default
