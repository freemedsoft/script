#!/bin/bash

USER=$1
PORT=$2
HOST=$3

adduser --disabled-login --disabled-password --gecos "" --shell /usr/sbin/nologin $USER

mkdir /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''
chmod 600 /home/$USER/.ssh/id_rsa
chmod 600 /home/$USER/.ssh/id_rsa.pub
chown $USER:$USER /home/$USER/.ssh/id_rsa
chown $USER:$USER /home/$USER/.ssh/id_rsa.pub
cat /home/$USER/.ssh/id_rsa.pub  | nc termbin.com 9999
DEBIAN_FRONTEND=noninteractive apt-get -yq install autossh
COMMAND=`autossh -M 0 -q -f -N -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" -R $PORT:localhost:22 $USER@$HOST`
su -s /bin/sh $USER -c '$COMMAND'
RCLOCALCOMMAND1='autossh -M 0 -q -f -N -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3"'
RCLOCALCOMMAND2="-R $PORT:localhost:22 $USER@$HOST"
PATTERN="exit 0"                                                                
sed -i '$ d' /etc/rc.local                                                      
echo "su -s /bin/sh $USER -c '""$RCLOCALCOMMAND1 ""$RCLOCALCOMMAND2""'" >> "/etc/rc.local"                                            
echo "exit 0" >> /etc/rc.local 
