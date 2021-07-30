#!/bin/bash
clear
IP=$(wget -qO- ipv4.icanhazip.com)
apt-get install stunnel4
openssl genrsa 2048 > stunnel.key
openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
cat stunnel.crt stunnel.key > stunnel.pem
mv stunnel.pem /etc/stunnel/
echo "pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
[ssh]
accept = $IP:443
connect = 127.0.0.1:22" >> /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
service stunnel4 start
echo "Stunnel is now running"
wget https://raw.githubusercontent.com/ThusharaX/vpsmanager/main/vpsmanagersetup.sh
chmod +x vpsmanagersetup.sh
./vpsmanagersetup.sh
exit 1