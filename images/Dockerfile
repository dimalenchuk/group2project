FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y apache2
RUN apt-get install -y php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

RUN apt install  -y wget

RUN wget -O /var/www/html/20180706_novinano_sv_0e61d66b99566e5c1751180706065615_archive.zip https://github.com/mplesha/NoviNano/releases/download/v1.0/20180706_novinano_sv_0e61d66b99566e5c1751180706065615_archive.zip
RUN wget -O ~/20180706_novinano_sv_0e61d66b99566e5c1751180706065615_installer.php https://github.com/mplesha/NoviNano/releases/download/v1.0/20180706_novinano_sv_0e61d66b99566e5c1751180706065615_installer.php
RUN mv ~/20180706_novinano_sv_0e61d66b99566e5c1751180706065615_installer.php /var/www/html/installer.php
RUN rm /var/www/html/index.html
RUN chown -R www-data:www-data /var/www/html

CMD ["apachectl","-D","FOREGROUND"]
RUN a2enmod rewrite
RUN service apache2 restart


EXPOSE 80
EXPOSE 443
