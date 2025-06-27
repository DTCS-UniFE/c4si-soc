# Adattato da https://writing.pupius.co.uk/apache-and-php-on-docker-44faef716150
# e https://github.com/noenv/docker-wazuh-agent
#FROM debian:12
FROM i386/debian:12

# La versione a 32 bit permette di effettuare exploit di sqlmap
# automaticamente, e non introduce nuove vulnerabilità. Per tutto
# il resto si può usare la versione a 64 bit.

ARG DEBIAN_FRONTEND=noninteractive

# Per data/ora corretti
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get -y install tzdata \
    && dpkg-reconfigure -f noninteractive tzdata


####################
##### Installo l'agente Wazuh
####################

# Installa l'agente Wazuh
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    curl \
    gnupg2 \
    procps \
    apt-transport-https

# NB: La versione dell'agent deve essere uguale o inferiore a quella del manager.
# Noi usiamo la versione 4.12.0 sia per l'agente che per il manager.
# NB 2: Vanno settate le variabili d'ambiente WAZUH_MANAGER e WAZUH_AGENT_NAME;
# la prima definisce l'indirizzo del Wazuh Manager (es. "wazuh.manager") a cui l'agente
# si collegherà, la seconda definisce il nome con cui l'agente si identificherà.
# NB 3: Di solito impostiamo queste variabili d'ambiente nel docker-compose.yml in cui
# gestiamo anche Wazuh. In alternativa si possono definire di seguito.
# NB 4: Il nome dell'agente Wazuh sembra non venire registrato durante la build del container.
# Per essere sicuri, impostiamo il nome dell'agente nel file ossec.conf con sed a tempo di esecuzione.

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
    && apt-get install -y wazuh-agent=4.12.0-1


####################
##### Installo Apache, PHP e MySQL (MariaDB)
####################
# Cambiando la versione dell'immagine base può cambiare la versione dei pacchetti PHP,
# in questo modo è più facile impostarla.
ARG PHP_VER=8.2

RUN apt-get -y install \
    apache2 \
    php${PHP_VER} \
    php${PHP_VER}-mysql \
    libapache2-mod-php${PHP_VER} \
    mariadb-server

# Attiviamo dei moduli di Apache
RUN a2enmod php${PHP_VER}
RUN a2enmod rewrite

# Aggiorniamo il file php.ini, attiviamo i tag corti <? ?>, riduciamo il logging
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/${PHP_VER}/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/${PHP_VER}/apache2/php.ini

# Alcune variabili di ambiente per Apache
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid

# Configurazione di Apache per il nostro sito
COPY apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Fix per MariaDB
RUN mkdir /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld


####################
##### Installo Suricata
####################
RUN echo "deb http://deb.debian.org/debian/ bookworm-backports main" > /etc/apt/sources.list.d/bookworm-backports.sources.list
RUN apt-get update && apt-get install -y suricata
RUN suricata-update
# Copia le regole di suricata (file mergeato suricata.rules) in /etc/suricata/rules, il path di default
RUN cp /var/lib/suricata/rules/suricata.rules /etc/suricata/rules/suricata.rules


####################
##### Aggiungo un utente non-root
####################
RUN apt-get install -y sudo \
    && useradd gb -d /home/gb -s /bin/bash -m -G sudo \
    && echo 'Z2I6aHVudGVyMgo=' | base64 -d | chpasswd
#echo 'gb:hunter2' | chpasswd


####################
##### Copiamo la app e degli script
####################
# Copiamo la nostra app Web nel container
RUN rm -r /var/www/html
COPY app/. /var/www/html
RUN chown -R www-data:www-data /var/www/html
# Per rendere più facile l'exploit
RUN chmod -R 777 /usr/lib/mysql/plugin && chmod -R 777 /var/www/html

# Copiamo la nostra configurazione dell'agente Wazuh
COPY ossec.conf /var/ossec/etc/ossec.conf

# Aggiungiamo alla home dell'utente gb dei file (finti) interessanti
COPY honeyfiles/. /home/gb
RUN chown -R gb:gb /home/gb

COPY entrypoint.sh cyberbase.sql /

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# Useremo la porta 80 per la web app
EXPOSE 80

CMD [ "bash", "/entrypoint.sh" ]
