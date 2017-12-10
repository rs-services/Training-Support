#! /usr/bin/sudo /bin/bash
apt-get install -y apache2
echo $WEBTEXT > /var/www/index.html
echo ">>>> Placed WEBTEXT, $WEBTEXT into index.html"
service apache2  start
echo ">>>> Started apache2"
