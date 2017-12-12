#! /usr/bin/sudo /bin/bash
# ---
# RightScript Name: Install DeckOfCards API Server
# Inputs:
#   PRIVATE_IP_ADDR:
#     Category: Application
#     Description: The server's private IP address to which the service connects.
#     Input Type: single
#     Required: true
#     Advanced: false
#     Default: env:PRIVATE_IP
# Attachments: []
# ...

# Installs and launches the Deck of Cards API
# See: https://github.com/crobertsbmw/deckofcards.git

# Only tested wiht Ubuntu 16

apt-get install -y python-imaging python-pythonmagick python-markdown python-textile python-docutils

apt-get install -y git python-pip

apt-get install -y python-django

git clone https://github.com/crobertsbmw/deckofcards.git

cd deckofcards

pip install -r requirements.txt
python manage.py migrate

nohup python manage.py runserver $PRIVATE_IP_ADDR:8000 &

