#!/usr/bin/env bash
# shellcheck source=/dev/null

# Create and/or empty file:
sudo truncate --size=0 /etc/httpd/conf.d/php.conf

# Easy access for vagrant user:
sudo chown vagrant:vagrant /etc/httpd/conf.d/php.conf

cat << "EOF" > /etc/httpd/conf.d/php.conf
<VirtualHost *:80>
  DocumentRoot /var/www/test
  ServerName php.local
  ServerAlias www.php.local
  ErrorLog /var/log/httpd/php.local-error.log
  CustomLog /var/log/httpd/php.local-access.log combined
  <Directory /var/www/test>
    IndexOptions +FancyIndexing NameWidth=*
    Options -Indexes +Includes +FollowSymLinks +MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>
EOF

sudo systemctl restart httpd
