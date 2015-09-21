#!/bin/sh
echo $WEBTEXT > /var/www/html/index.html
echo ">>>> Placed WEBTEXT, $WEBTEXT into index.html"
service httpd start
echo ">>>> Started httpd"
