#!/bin/bash

USER=$1
CODE=$2

adduser --disabled-login --disabled-password --gecos "" --shell /usr/sbin/nologin $USER

mkdir /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
chmod 644 /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh/authorized_keys
wget  http://termbin.com/$CODE
cat "$CODE" >> "/home/$USER/.ssh/authorized_keys"
rm $CODE
