#!/bin/sh
#
# File /etc/apache2/sites-available/vhost_tpl.sh
#
# Usage example:
#   cd /etc/apache2/sites-available
#
#   HOSTNAME=example.com ./vhost_tpl.sh > example.com.conf
#   HOSTNAME=example.net ./vhost_tpl.sh > example.net.conf
#   HOSTNAME=example.org ./vhost_tpl.sh > example.org.conf
#
#   a2ensite example.com.conf example.net.conf example.org.conf
#   service apache2 reload
#

if [ -z "$SERVER_ADMIN" ]
then
  SERVER_ADMIN="root@localhost"
fi

cat - <<VIRTUAL_HOST_TEMPLATE
<VirtualHost *:80>
    ServerAdmin $SERVER_ADMIN

    ServerName $HOSTNAME
    # ServerAlias www.$HOSTNAME

    DocumentRoot /var/www/$HOSTNAME
    <Directory /var/www/$HOSTNAME>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        Satisfy Any
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$HOSTNAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$HOSTNAME-access.log combined
</VirtualHost>

<IfModule ssl_module>
<IfFile "/var/www/acme/$HOSTNAME/certificate.pem">
<VirtualHost *:443>
    ServerAdmin $SERVER_ADMIN

    ServerName $HOSTNAME

    DocumentRoot /var/www/$HOSTNAME
    <Directory /var/www/$HOSTNAME>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        Satisfy Any
    </Directory>

    SSLEngine                       on
    SSLCertificateFile              /var/www/acme/$HOSTNAME/certificate.pem
    SSLCertificateKeyFile           /var/www/acme/$HOSTNAME/private_key.pem
    SSLCertificateChainFile         /var/www/acme/lets-encrypt-x3-cross-signed.pem

    ErrorLog \${APACHE_LOG_DIR}/$HOSTNAME-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/$HOSTNAME-ssl-access.log combined
</VirtualHost>
</IfFile>
</IfModule>
VIRTUAL_HOST_TEMPLATE
