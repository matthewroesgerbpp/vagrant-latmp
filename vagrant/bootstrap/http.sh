#!/usr/bin/env bash

UPDATE

MESSAGE "Installing Apache HTTP Server"

# Install Apache:
sudo yum --assumeyes install httpd

# Create and/or empty file:
sudo truncate --size=0 /etc/httpd/conf.d/http.conf

# Easy access for vagrant user:
sudo chown vagrant:vagrant /etc/httpd/conf.d/http.conf

# Write conf data:
cat << "EOF" > /etc/httpd/conf.d/http.conf
<VirtualHost *:80>
  DocumentRoot /var/www/html/test
  ServerName http.local
  ServerAlias www.http.local
  ErrorLog /var/log/httpd/http.local-error.log
  CustomLog /var/log/httpd/http.local-access.log combined
  <Directory /var/www/html/test>
    IndexOptions +FancyIndexing NameWidth=*
    Options -Indexes +Includes +FollowSymLinks +MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>
EOF

# Vagrant shared folders should have done this already:
sudo chown -R vagrant:vagrant /var/www

# Remove existing test site directory (if it exists):
rm --recursive --force /var/www/html/test

# Create the test site directory:
mkdir --parents /var/www/html/test

# Create an index file:
cat << "EOF" > /var/www/html/test/index.php
<!DOCTYPE html>
<html>
  <head>
    <title>Apache HTTP Server</title>
  </head>
  <body>
    <h3>PHP version: <?=phpversion()?></h3>
    <p><a href="phpinfo.php">phpinfo</a></p>
  </body>
</html>
EOF

# For the hell of it:
echo "<?=phpinfo()?>" > /var/www/html/test/phpinfo.php

# Set Apache service to start on boot:
sudo systemctl enable httpd

# Start Apache:
sudo systemctl start httpd
