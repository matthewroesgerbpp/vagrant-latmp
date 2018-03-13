#!/usr/bin/env bash

MESSAGE() {

  echo
  echo "---------------------------------------------"
  echo $1 | awk '{ print toupper($0) }'
  echo "---------------------------------------------"
  echo

}

UPDATE() {
  
  MESSAGE "UPDATING PACKAGES"
  
  # Sync the rpmdb or yumdb database contents:
  yum history sync
  
  # Clean-up yum:
  yum clean all
  
  # Free up space:
  rm -rf /var/cache/yum
  
  # Update packages:
  yum -y update
  
}

APACHE() {
  
  if [ "`systemctl is-active httpd`" != "active" ]; then
    systemctl start httpd
  else
    systemctl restart httpd
  fi
  
}

#-----------------------------------------------------------------------

while getopts e:m:t:v:n: OPTION
do
  case ${OPTION} in
    e)
      PHP_MAX_EXECUTION_TIME=${OPTARG}
      ;;
    m)
      PHP_MEMORY_LIMIT=${OPTARG}
      ;;
    t)
      PHP_TIMEZONE=${OPTARG}
      ;;
    v)
      PHP_VERSION=${OPTARG//[-._]/} # This: "//[-._]/", removes the period.
      ;;
    n)
      NODE_VERSION=${OPTARG} # This: "//[-._]/", removes the period.
      ;;
    *)
      echo "Invalid arg ... Exiting!" >&2 # Is this really needed?
      exit 1
      ;;
  esac
done

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing Packages"

yum -y install \
  kernel-devel \
  kernel-headers \
  gcc-c++ \
  git \
  make \
  nano \
  ruby \
  ruby-devel \
  rubygems \
  sqlite-devel \
  telnet \
  unzip \
  wget \
  yum-utils \
  zip
  # What else?

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Updating Firewall"

yum -y install firewalld

# Set firewall service to auto start:
#systemctl enable firewalld

systemctl start firewalld

# Allow HTTP and HTTPS web traffic in the “public” zone, permanently:
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

# Open HTTP port in the “public” zone, permanently:
firewall-cmd --permanent --zone=public --add-port=80/tcp
# HTTPS:
firewall-cmd --permanent --zone=public --add-port=443/tcp
# MySQL:
firewall-cmd --permanent --zone=public --add-port=3306/tcp

# Flush iptables:
iptables -F

# Reload the firewall:
firewall-cmd --reload

# Disable the firewall for development’s sake:
systemctl disable firewalld

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing Apache HTTP Server"

# Install Apache:
yum -y install httpd

# Set Apache service to auto start:
systemctl enable httpd

# Make sure we’re working with an empty file:
:> /etc/httpd/conf.d/vagrant.conf

# Add conf data:
cat << EOF >> /etc/httpd/conf.d/vagrant.conf
##############################################
#                                            #
#                                            #
#  ██████    █████   ██     ██  ██████   ██  #
#  ██   ██  ██   ██  ██     ██  ██   ██  ██  #
#  ██████   ███████  ██  █  ██  ██████   ██  #
#  ██   ██  ██   ██  ██ ███ ██  ██   ██      #
#  ██   ██  ██   ██   ███ ███   ██   ██  ██  #
#                                            #
#                                            #
#          DO NOT EDIT THIS FILE!            #
#                                            #
#                                            #
##############################################
ServerName localhost
User vagrant
Group vagrant
EnableSendfile off
<Directory "/var/www/html">
  AllowOverride All
</Directory>
<VirtualHost *:80>
  DocumentRoot "/var/www/html/test"
  ServerName "http.local"
  ServerAlias "www.http.local"
  ErrorLog "/var/log/httpd/http.local-error.log"
  CustomLog "/var/log/httpd/http.local-access.log" combined
  <Directory "/var/www/html/test">
    IndexOptions +FancyIndexing NameWidth=*
    Options -Indexes +Includes +FollowSymLinks +MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>
EOF

# Remove existing test site directory (if it exists):
rm -rf /var/www/html/test

# Create the test site directory:
mkdir /var/www/html/test

# Create an index file:
cat << EOF > /var/www/html/test/index.php
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

# Start Apache:
APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing Apache Tomcat Server"

# Install Java (CentOS will find the correct SDK with the `-devel` sufix):
yum -y install java-sdk

# Install Tomcat:
yum -y install tomcat

# Start Tomcat:
systemctl start tomcat

# Set Tomcat to run every time the server is booted up:
systemctl enable tomcat

# Append this to the end of our conf file:
cat << EOF >> /etc/httpd/conf.d/vagrant.conf
<VirtualHost *:80>
  ServerName "tomcat.local"
  ServerAlias "www.tomcat.local"
  ErrorLog "/var/log/httpd/tomcat.local-error.log"
  CustomLog "/var/log/httpd/tomcat.local-access.log" combined
  ServerName "tomcat.local"
  ServerAlias "www.tomcat.local"
  ProxyRequests Off
  ProxyPass "/" "ajp://localhost:8009/test/"
  ProxyPassReverse "/" "ajp://localhost:8009/test/"
  ProxyPassReverseCookiePath "/test" "/"
  ProxyPassReverseCookieDomain "localhost" "tomcat.local"
  Header always set Access-Control-Allow-Origin "*"
  Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT"
  Header always set Access-Control-Max-Age "1000"
  Header always set Access-Control-Allow-Headers "x-requested-with, Content-Type, origin, authorization, accept, client-security-token"
</VirtualHost>
EOF

# Probably need to edit this:
# /usr/lib/systemd/system/tomcat
# … and add this:
# Environment=JAVA_HOME=/usr/lib/jvm/jre

# Remove existing test site directory (if it exists):
rm -rf /var/lib/tomcat/webapps/test

# Create the test site directory:
mkdir /var/lib/tomcat/webapps/test

# Create an index file:
cat << EOF > /var/lib/tomcat/webapps/test/index.jsp
<!DOCTYPE html>
<html>
  <head>
    <title>Apache Tomcat Server</title>
  </head>
  <body>
    <h3>
      Tomcat version: <%=application.getServerInfo()%>
      <br>  
      Java Runtime version: <%=System.getProperty("java.version") %>
      <br>
      Servlet Specification version: <%=application.getMajorVersion()%>.<%=application.getMinorVersion()%>
      <br>    
      Java Server Page (JSP) version: <%=JspFactory.getDefaultFactory().getEngineInfo().getSpecificationVersion()%>
    </h3>
  </body>
</html>
EOF

# https://stackoverflow.com/a/40425151/922323
systemctl daemon-reload

# Restart Tomcat:
systemctl restart tomcat

# Start Apache:
APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Prepping to install PHP"

# https://rpms.remirepo.net/wizard/
# Install the EPEL repository configuration package
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Install the Remi repository configuration package:
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
# Install the yum-utils package:
yum -y install yum-utils

# Enable the php56, php70, php71, or php72 repository:
yum-config-manager --enable remi-php${PHP_VERSION}

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing PHP"

# PHP Modules array:
PHP_MODULES=(
  bcmath
  fpm
  gd
  intl
  mbstring
  mcrypt
  memcache
  memcached
  mysqli
  opcache
  pear
  tidy
  zip
)

# Install PHP and additional packages (using Parameter Expansion):
yum -y install php "${PHP_MODULES[@]/#/php-}"

# Ensure FastCGI Process Manager starts automatically:
systemctl enable php-fpm
systemctl start php-fpm

# Use the develpment configuration file (only applicable to php >= 7):
cp -f /usr/share/doc/php-*/php.ini-development /etc/php.ini
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php.ini
sed -i "s#;date\.timezone.*#date\.timezone = ${PHP_TIMEZONE}#g" /etc/php.ini # Using `#` as delim.
sed -i "s/memory_limit.*/memory_limit = ${PHP_MEMORY_LIMIT}M/g" /etc/php.ini
sed -i "s/max_execution_time.*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" /etc/php.ini

if [ -d /var/lib/php/session ]; then
  chown -R vagrant: /var/lib/php/session
fi

# Check the installed version and available extensions:
php --version
php --modules

APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing Composer"

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

composer config -g optimize-autoloader true

# Use this to check and update to latest version of Composer:
composer self-update

APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing MySQL"

# https://dev.mysql.com/downloads/repo/yum/
yum -y localinstall http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# install MySQL server:
yum -y install mysql-community-server

# Start the MySQL service:
systemctl start mysqld

# Set the MySQL service to auto start:
systemctl enable mysqld

# Set root password:
mysqladmin -u root password 'password'
# Change root password:
# mysqladmin -uroot -poldpassword password newpassword

# Restart the MySQL service:
systemctl restart mysqld

APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing Node.js"

# Node.js v8 LTS:
curl --silent --location https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -

yum -y install nodejs

# Turn off bin links by default:
npm config set bin-links false

# https://github.com/npm/npm/issues/17146
npm cache clear --force

# Process manager:
npm install -g pm2

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing phpMyAdmin"

# Make sure EPEL repo installed (Extra Packages for Enterprise Linux):
yum -y install epel-release

# Install PhpMyAdmin package:
yum -y install phpmyadmin

cat << EOF > /etc/httpd/conf.d/phpMyAdmin.conf
Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin
<Directory /usr/share/phpMyAdmin/>
  AddDefaultCharset UTF-8
  Options Indexes FollowSymLinks
  Order allow,deny
  Allow from all
  Require all granted
</Directory>
EOF

# Custom configuration:
# https://stackoverflow.com/a/29598833/922323
chmod 755 /etc/phpMyAdmin
chmod 644 /etc/phpMyAdmin/config.inc.php

# Fixes for phpmyadmin (configuration storage and some extended features):
curl -Ok \
https://raw.githubusercontent.com/skurudo/phpmyadmin-fixer/master/pma-centos.sh \
&& chmod +x pma-centos.sh && ./pma-centos.sh

APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------

MESSAGE "Installing MailCatcher"

# Creating `pathmunge` file:
cat << EOF >> /etc/profile.d/local-bin.sh
#!/usr/bin/env bash
pathmunge /usr/local/bin after
EOF

# Install MailCatcher:
gem install -N mailcatcher

# Enable MailCatcher in php:
sed -ri '/sendmail_path\s+=.*/a sendmail_path = /usr/bin/env catchmail' /etc/php.ini

# Start MailCatcher:
if [ -x /usr/local/bin/mailcatcher ]; then
  /usr/local/bin/mailcatcher --ip=0.0.0.0
fi

APACHE

#-----------------------------------------------------------------------

UPDATE

#-----------------------------------------------------------------------
