#!/bin/bash
#step1
add-apt-repository universe
apt-get update
apt-get upgrade
apt-get install autoconf automake build-essential cmake gcc gfortran git libblas-dev libbz2-dev libcurl4-gnutls-dev liblapack-dev libltdl-dev liblzma-dev libncurses5-dev libssl-dev libxrender-dev libxtst-dev make openjdk-8-jre openjdk-11-jre parallel perl pigz python3-pip rename tree unzip zlib1g-dev python3-testresources r-base python3-certbot-apache libapache2-mod-php7.4 nodejs cockpit cockpit-bridge cockpit-ws npm
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
groupadd bioinformatics
echo "atgenomics.ddns.net" > /etc/hostname
hostname atgenomics.ddns.net
#step3
cd /usr/bin
ln -s python3 python
pip3 install powerline-shell
echo "
function _update_ps1() {
	PS1=\$(powerline-shell \$?)
	}
if [[ \$TERM != linux && ! \$PROMPT_COMMAND =~ _update_ps1 ]]
then
	PROMPT_COMMAND=\"_update_ps1; \$PROMPT_COMMAND\"
fi" >>  /etc/profile
#step4
for user in jmartinez equiroz cmendez jhernandez jpozo fquiroz avenancio adesales covando mluis imartinez mmoreno agomez lhernandez lgalvez asavin zzatarain dtachiquin selva gpalomino earechiga lortiz solnavss vflorelo dianolasa zorbax
do
  useradd --create-home --gid bioinformatics --shell /bin/bash $user
  echo -e "${user}atg\n${user}atg" | passwd $user
  mkdir /home/$user/.ssh
  cp /home/ubuntu/.ssh/authorized_keys /home/$user/.ssh
  chown -R $user /home/$user/.ssh
  chgrp -R bioinformatics /home/$user/.ssh
  chmod -R 700 /home/$user/.ssh
  echo "source /etc/profile" >> /home/user/.bashrc
done
#step5
cd /var/www
rm -rf html
wget https://github.com/vflorelo/atgserver/raw/main/html.tar.gz
tar -zxf html.tar.gz
#step6
certbot --apache
cd /etc/letsencrypt/archive/atgenomics.ddns.net
cat cert1.pem privkey1.pem > /etc/cockpit/ws-certs.d/0-atg.cert
cd /etc/cockpit/ws-certs.d/
chmod 640 0-atg.cert
rm 0-self-signed.cert
service apache restart
service cockpit restart
