#! /usr/bin/sudo /bin/bash
# ---
# RightScript Name: training_helloworld_update_rightscript
# Inputs:
#   WEBTEXT:
#     Category: Application
#     Description: Text to display on web page.
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: text:Hello World!
# Attachments: []
# ...
echo $WEBTEXT > /var/www/index.html
echo ">>>> Placed WEBTEXT, $WEBTEXT into index.html"
service apache2  restart
echo ">>>> Started apache2"
