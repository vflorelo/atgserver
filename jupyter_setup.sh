#!/bin/bash
#step1
add-apt-repository universe
apt-get update
apt-get upgrade
apt-get install autoconf automake build-essential cmake gcc gfortran git libblas-dev libcurl4-gnutls-dev liblapack-dev libltdl-dev libssl-dev libxrender-dev libxtst-dev make python3-pip python3-certbot-apache libapache2-mod-php7.4 nodejs npm cockpit cockpit-ws
npm install -g configurable-http-proxy
pip3 install jupyterhub
#step2
wget http://www.noip.com/client/linux/noip-duc-linux.tar.gz
tar -zxf noip-duc-linux.tar.gz
cd noip-2.1.9-1
make install
echo "[Unit]
Description=noip2 service
[Service]
Type=forking
ExecStart=/usr/local/bin/noip2
Restart=always
[Install]
WantedBy=default.target" > /etc/systemd/system/noip2.service
systemctl daemon-reload
systemctl enable noip2.service
service noip2 restart
echo "atgenomics.ddns.net" > /etc/hostname
hostname atgenomics.ddns.net
#step3
cd /usr/bin
ln -s python3 python
pip3 install powerline-shell
pip3 install  --upgrade notebook
echo "
function _update_ps1() {
  PS1=\$(powerline-shell \$?)
  }
if [[ \$TERM != linux && ! \$PROMPT_COMMAND =~ _update_ps1 ]]
then
  PROMPT_COMMAND=\"_update_ps1; \$PROMPT_COMMAND\"
fi" >>  /etc/profile
#step4
groupadd bioinformatics
for user in solnavss dianolasa zorbax vflorelo
do
  useradd --create-home --gid bioinformatics --shell /bin/bash $user
  echo -e "${user}atg\n${user}atg" | passwd $user
  mkdir /home/$user/.ssh
  cp /home/ubuntu/.ssh/authorized_keys /home/$user/.ssh
  chown -R $user /home/$user/.ssh
  chgrp -R bioinformatics /home/$user/.ssh
  chmod -R 700 /home/$user/.ssh
  echo "source /etc/profile" >> /home/$user/.bashrc
done
#step5
certbot --apache
cert_dir="/etc/letsencrypt/archive/atgenomics.ddns.net"
cat ${cert_dir}/cert1.pem ${cert_dir}/privkey1.pem > /etc/cockpit/ws-certs.d/0-atg.cert
chmod 640 /etc/cockpit/ws-certs.d/0-atg.cert
service apache2 restart
service cockpit restart
mkdir -p /etc/jupyterhub
chmod -R 700 /etc/jupyterhub
cd /lib/systemd/system
wget https://github.com/vflorelo/atgserver/raw/main/jupyterhub.service
cd /etc/init.d
wget https://github.com/vflorelo/atgserver/raw/main/jupyterhub
chmod 755 jupyterhub
cd /etc/jupyterhub
wget https://github.com/vflorelo/atgserver/raw/main/jupyter_atg.py
systemctl daemon-reload
service jupyterhub start
