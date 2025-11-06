# Adapted from https://writing.pupius.co.uk/apache-and-php-on-docker-44faef716150
# and https://github.com/noenv/docker-wazuh-agent
#FROM debian:12
FROM i386/debian:12

# The 32-bit version allows sqlmap exploits automatically,
# and does not introduce new vulnerabilities. For everything
# else, you can use the 64-bit version.

ARG DEBIAN_FRONTEND=noninteractive

# For correct date/time
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get -y install tzdata \
    && dpkg-reconfigure -f noninteractive tzdata


####################
##### Install Wazuh agent
####################

# Install the Wazuh agent
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    curl \
    gnupg2 \
    procps \
    apt-transport-https

# Note 1: The agent version must be equal to or lower than the manager version.
# We use version 4.14.0 for both the agent and the manager.
# Note 2: The environment variables WAZUH_MANAGER and WAZUH_AGENT_NAME must be set;
# the first defines the address of the Wazuh Manager (e.g. "wazuh.manager") to which the agent
# will connect, the second defines the name with which the agent will identify itself.
# Note 3: Usually we set these environment variables in the docker-compose.yml where
# we also manage Wazuh. Alternatively, they can be defined below.
# Note 4: The Wazuh agent name does not seem to be registered during the container build.
# To be sure, we also set the agent name in the ossec.conf file with sed at runtime.

#ARG WAZUH_MANAGER=wazuh.manager
#ARG WAZUH_AGENT_NAME=agent47-wazuh

ARG WAZUH_MANAGER
ARG WAZUH_AGENT_NAME

ENV WAZUH_MANAGER=${WAZUH_MANAGER}
ENV WAZUH_AGENT_NAME=${WAZUH_AGENT_NAME}

RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH \
        | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import \
    && chmod 644 /usr/share/keyrings/wazuh.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
        | tee -a /etc/apt/sources.list.d/wazuh.list \
    && apt-get update \
    && apt-get install -y wazuh-agent=4.14.0-1


####################
##### Install Apache, PHP and MySQL (MariaDB)
####################
# Changing the base Docker image may change the PHP package version,
# this way it is easier to set it everywhere it's needed.
ARG PHP_VER=8.2

RUN apt-get -y install \
    apache2 \
    php${PHP_VER} \
    php${PHP_VER}-mysql \
    libapache2-mod-php${PHP_VER} \
    mariadb-server

# Enable some Apache modules
RUN a2enmod php${PHP_VER}
RUN a2enmod rewrite

# Update the php.ini file, enable short tags <? ?>, reduce logging
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/${PHP_VER}/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/${PHP_VER}/apache2/php.ini

# Some environment variables for Apache
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid

# Apache configuration for our site
COPY apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Fix for MariaDB
RUN mkdir /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld


####################
##### Install Suricata
####################
RUN echo "deb http://deb.debian.org/debian/ bookworm-backports main" > /etc/apt/sources.list.d/bookworm-backports.sources.list
RUN apt-get update && apt-get install -y suricata
RUN suricata-update
# Copy Suricata rules (merged suricata.rules file) to /etc/suricata/rules, the default path
RUN cp /var/lib/suricata/rules/suricata.rules /etc/suricata/rules/suricata.rules


####################
##### Add a non-root user
####################
RUN apt-get install -y sudo \
    && useradd gb -d /home/gb -s /bin/bash -m -G sudo \
    && echo 'Z2I6aHVudGVyMgo=' | base64 -d | chpasswd
#echo 'gb:hunter2' | chpasswd


####################
##### Copy the app and scripts
####################
# Copy our web app into the container
RUN rm -r /var/www/html
COPY app/. /var/www/html
RUN chown -R www-data:www-data /var/www/html
# To make exploitation easier
RUN chmod -R 777 /usr/lib/mysql/plugin && chmod -R 777 /var/www/html

# Copy our Wazuh agent configuration
COPY ossec.conf /var/ossec/etc/ossec.conf

# Add some (fake) interesting files to the gb user's home
COPY honeyfiles/. /home/gb
RUN chown -R gb:gb /home/gb

COPY entrypoint.sh cyberbase.sql /

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# We will use port 80 for the web app
EXPOSE 80

CMD [ "bash", "/entrypoint.sh" ]
