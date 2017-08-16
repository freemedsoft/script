#!/bin/bash

USER=$1
PORT=$2
HOST=$3
LOGIN=$4
PASSWORD=$5
FINGERPRINT1="|1|LRCP3Gs5pMEFUk+adQoO8PJ7pBs=|sP251xenPesFDcMIP1ys651L2lw= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwZgxUccuEqDFwc+HL6RjviX1q8cAf+nlBa4IL/VK2BWdpOf2WIDl+8gSqvB3iScqUpDPYsPmGzLT+N/dO2b17R+2RuqU5sEnaOMSembgzzo1M9bk/FKe/UOcbXOsr8VRYweuADV47CuDUxfRie5ZwSnD2TKPvrE425mfSWK4K8Lm85qMQn4YLvDFHnXMDgb8In1ArfTqvWDf7uOLCoNAqq+VCQUS5rzN1f4CzlXYfMaAYoD/sgKgUYBrJxU/0o2LVRGqE0TwCDoW+OJekoWhYQTqjYVVPP8IDLxmxGmj4LgTNtqSImqF5B+aFJgD0O9ogQCrGZPUhc58o6mhesFln"
FINGERPRINT2="|1|/CK7JJsAqil8a3KFt++f2nzTzi8=|W06rOQtKoWEEVFJbOzmV2dR/VaM= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPrsizP+CZG7ymocAWoLO6caMpJaja+5JM2IfNjRxefX+ZLGO8Un/Lz7jJM6l11x66XN2ImbAtNixeuZ3LW5gug=
|1|ufysVPR18uOhbjjo41s/dKfzLH4=|Sl625FOhoCKnMSoDla48Rq/4W5k= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2sgbKKKKDi3GRS7fNbgJU4ARuQv/9jSqRCUpuFNXyG"

adduser --disabled-login --disabled-password --gecos "" --shell /bin/false $USER

mkdir /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''
chmod 600 /home/$USER/.ssh/id_rsa
chmod 600 /home/$USER/.ssh/id_rsa.pub
chown $USER:$USER /home/$USER/.ssh/id_rsa
chown $USER:$USER /home/$USER/.ssh/id_rsa.pub

touch /home/$USER/.ssh/known_hosts
echo "$FINGERPRINT1" >> /home/$USER/.ssh/known_hosts
echo "$FINGERPRINT2" >> /home/$USER/.ssh/known_hosts
chown $USER:$USER /home/$USER/.ssh/known_hosts                                  
chmod 600 /home/$USER/.ssh/known_hosts

DEBIAN_FRONTEND=noninteractive apt-get -yq install autossh lftp


# upload public key
# use termbin.com
# cat /home/$USER/.ssh/id_rsa.pub  | nc termbin.com 9999

# use vsftpd with tls
FILE="$USER_info"
KEY="$USER_key"
touch $FILE
echo "$USER" >> $FILE
cat /home/$USER/.ssh/id_rsa.pub >> $FILE
echo "$PORT" >> $FILE

touch $KEY
cat cat /home/$USER/.ssh/id_rsa.pub >> $KEY

lftp -c "open -u $LOGIN,$PASSWORD ftp.$HOST; put -O files $FILE"
lftp -c "open -u $LOGIN,$PASSWORD ftp.$HOST; put -O files $KEY"

rm $FILE
rm $KEY

COMMAND=`autossh -M 0 -q -f -N -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" -R $PORT:localhost:22 $USER@tunnel.$HOST`
su -s /bin/sh $USER -c '$COMMAND'
RCLOCALCOMMAND1='autossh -M 0 -q -f -N -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3"'
RCLOCALCOMMAND2="-R $PORT:localhost:22 $USER@ssh.$HOST"
PATTERN="exit 0"                                                                
sed -i '$ d' /etc/rc.local                                                      
echo "su -s /bin/sh $USER -c '""$RCLOCALCOMMAND1 ""$RCLOCALCOMMAND2""'" >> "/etc/rc.local"                                            
echo "exit 0" >> /etc/rc.local 
