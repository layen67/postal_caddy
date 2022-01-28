#!/bin/sh

set -e

read -p "Please enter domain:" domainname
read -p "Please enter Msql password: LFr37rG3r " domainpasspw
read -p "Please enter your Freenom.com email login:" Freenomloginpw
read -p "Please enter your Freenom.com password:" Freenompasspw

# freenom install
apt-get update;
apt install git -y;
git clone https://github.com/dawierha/Freenom-dns-updater.git;
cd Freenom-dns-updater;
apt-get install -y software-properties-common;
add-apt-repository -y ppa:deadsnakes/ppa;
apt-get update;
apt-get install -y python3-setuptools;
apt-get install -y python3.6;
python3 setup.py install;
apt-get install -y python3-click;


echo "
login: $Freenomloginpw
password: $Freenompasspw
# list here the records you want to add/update
record:
  # the following will update both the A and AAAA records with your current ips (v4 and v6).
  # Note that if you don't have a ipv6 connection, the program'll detect it and will only update the A record (ipv4)
  - domain: $domainname
  # the following will update both your subdomain's A and AAAA records with your current ips (v4 and v6)
  - domain: $domainname
    name: www
  # the following will update both your subdomain's A and AAAA records with your current ips (v4 and v6)
  - domain: $domainname
    name: mx.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: click
    type: CNAME
    target: track.postal.$domainname # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: mta-sts.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: rp.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: spf.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: track.postal
    
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: offert.postal
    type: CNAME
    target: news.kretonbiz.tk # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: 
    type: TXT
    target: v=spf1 a mx include:spf.postal.$domainname ~all # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: rp.postal
    type: TXT
    target: v=spf1 a mx include:spf.postal.$domainname ~all # you can omit this line
    
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: POSTAL-MODIFIER._DOMAINKEY
    type: TXT
    target: v=DKIM1; t=s; h=sha256; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDGCaSFpYj86cSSJpyQhs505MGoPdtfvgBryr2jlRppEQfJXkEP8uG39iLDvoLogyHNaYzsbVJL/3HBb80fnTxlYA454WMUZ0ndnnQ9Ue9AGA3Sd7tVPqaRyX0epZ2zA2/Yy+CJ5nEebt6apeUyGCGyiw+uRvnx/o0KzKk8uGPgTQIDAQAB; # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: psrp
    type: CNAME
    target: rp.postal.$domainname # you can omit this line
    
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: _DMARC
    type: TXT
    target: v=DMARC1; p=quarantine; rua=mailto:abuse@$domainname # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name:
    type: MX
    target: postal.$domainname # you can omit this line
    priority: 10
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: routes.postal
    type: MX
    target: postal.$domainname # you can omit this line
    priority: 10
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: postal
    type: MX
    target: postal.$domainname # you can omit this line
    priority: 10
    # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: postal
    type: TXT
    target: v=spf1 a mx include:spf.postal.$domainname ~all # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: psrp.postal
    type: CNAME
    target: rp.postal.$domainname # you can omit this line
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: offert.postal
    type: CNAME
    target: news.foxelo.ga # you can omit this line  
"> /etc/freenom.yml;
fdu process -c -i -t 3600 /etc/freenom.yml&

apt update;
apt install spamassassin -y;
apt install git curl jq -y;
git clone https://postalserver.io/start/install /opt/postal/install;
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal;
apt-get update;apt-get install -y docker.io;
curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

docker run -d \
   --name postal-mariadb \
   -p 127.0.0.1:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=$domainpasspw \
   mariadb

docker run -d \
   --name postal-rabbitmq \
   -p 127.0.0.1:5672:5672 \
   --restart always \
   -e RABBITMQ_DEFAULT_USER=postal \
   -e RABBITMQ_DEFAULT_PASS=$domainpasspw \
   -e RABBITMQ_DEFAULT_VHOST=postal \
   rabbitmq:3.8
   
postal bootstrap postal.$domainname;
  
sed -i -e '/^smtp_server:/d' /opt/postal/config/postal.yml
sed -i -e '/^  port: 25/d' /opt/postal/config/postal.yml

echo '' | sudo tee -a /opt/postal/config/postal.yml;
echo 'smtp_server:' | sudo tee -a /opt/postal/config/postal.yml;
echo '  port: 25' | sudo tee -a /opt/postal/config/postal.yml;
echo '  tls_enabled: true' | sudo tee -a /opt/postal/config/postal.yml;
echo '  # tls_certificate_path: ' | sudo tee -a /opt/postal/config/postal.yml;
echo '  # tls_private_key_path: ' | sudo tee -a /opt/postal/config/postal.yml;
echo '  proxy_protocol: false' | sudo tee -a /opt/postal/config/postal.yml;
echo '  log_connect: true' | sudo tee -a /opt/postal/config/postal.yml;
echo '  strip_received_headers: true' | sudo tee -a /opt/postal/config/postal.yml;

sed -i -e "s/example.com/$domainname/g" /opt/postal/config/postal.yml;
sed -i -e "s/mx.postal.$domainname/postal.$domainname/g" /opt/postal/config/postal.yml;
sed -i -e "s/bind_address: 127.0.0.1/bind_address: 0.0.0.0/g" /opt/postal/config/postal.yml;
sed -i -e "s/password: postal/password: $domainpasspw/g" /opt/postal/config/postal.yml;

postal initialize;

fdu process -c -i -t 3600 /etc/freenom.yml&

postal make-user;


command hostnamectl set-hostname postal.$domainname;

postal stop;

sudo mkdir /opt/postal/config/wordpress;

echo "
version: '2'
services:
  https-portal:
    container_name: https-portal
    image: steveltn/https-portal:latest
    ports:
      - '80:80'
      - '443:443'
#    network_mode: host
    restart: always
    environment:
      STAGE: 'production'
      NUMBITS: '4096'
#        FORCE_RENEW: 'true'
      WORKER_PROCESSES: '4'
      WORKER_CONNECTIONS: '1024'
      KEEPALIVE_TIMEOUT: '65'
      GZIP: 'on'
      SERVER_NAMES_HASH_BUCKET_SIZE: '64'
      PROXY_CONNECT_TIMEOUT: '900'
      PROXY_SEND_TIMEOUT: '900'
      PROXY_READ_TIMEOUT: '900'
      CLIENT_MAX_BODY_SIZE: 300M
      DOMAINS: >-
          postal.$domainname -> http://172.17.0.1:5000,
          mta-sts.postal.$domainname -> http://172.17.0.1:5000,
          track.postal.$domainname -> http://172.17.0.1:5000
    volumes:
      - ./conf.d:/etc/nginx/conf.d/:rw
      - ./ssl_certs:/var/lib/https-portal:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
"> /opt/postal/config/wordpress/docker-compose.yml;

cd /opt/postal/config/wordpress;
docker-compose up -d;
sleep 20
chmod 777 ssl_certs/ -R;

sed -i -r "s/.*tls_certificate_path.*/  tls_certificate_path: \/config\/wordpress\/ssl_certs\/postal.$domainname\/production\/signed.crt/g" /opt/postal/config/postal.yml;
sed -i -r "s/.*tls_private_key_path.*/  tls_private_key_path: \/config\/wordpress\/ssl_certs\/postal.$domainname\/production\/domain.key/g" /opt/postal/config/postal.yml;

sed -i -e "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin;
systemctl restart spamassassin;

echo '' | sudo tee -a /opt/postal/config/postal.yml;
echo 'spamd:' | sudo tee -a /opt/postal/config/postal.yml;
echo '  enabled: true' | sudo tee -a /opt/postal/config/postal.yml;
echo '  host: 127.0.0.1' | sudo tee -a /opt/postal/config/postal.yml;
echo '  port: 783' | sudo tee -a /opt/postal/config/postal.yml;

#
# Installation 
#
sudo apt-get update -y;
apt-get install -y firewalld;
systemctl enable firewalld;
systemctl start firewalld;
firewall-cmd --add-port=80/tcp --permanent;
firewall-cmd --add-port=443/tcp --permanent;
firewall-cmd --add-port=25/tcp --permanent;
firewall-cmd --add-port=2525/tcp --permanent;
firewall-cmd --add-port=587/tcp --permanent;
firewall-cmd --add-port=465/tcp --permanent;
firewall-cmd --add-port=3306/tcp --permanent;
firewall-cmd --add-port=8000/tcp --permanent;
firewall-cmd --add-port=8082/tcp --permanent;
firewall-cmd --add-port=8080/tcp --permanent;
firewall-cmd --add-port=8088/tcp --permanent;
firewall-cmd --add-port=8443/tcp --permanent;
firewall-cmd --add-port=5000/tcp --permanent;
firewall-cmd --add-port=8089/tcp --permanent;
firewall-cmd --add-port=5672/tcp --permanent;
firewall-cmd --add-port=9443/tcp --permanent;
firewall-cmd --add-port=11443/tcp --permanent;
firewall-cmd --add-port=783/tcp --permanent;
firewall-cmd --add-port=4444/tcp --permanent;
firewall-cmd --add-port=4369/tcp --permanent;
firewall-cmd --add-port=25672/tcp --permanent;
firewall-cmd --add-port=5671-5672/tcp --permanent;

firewall-cmd --add-masquerade --permanent;
firewall-cmd --add-forward-port=port=2525:proto=tcp:toport=25 --permanent;
firewall-cmd --add-forward-port=port=465:proto=tcp:toport=25 --permanent;
firewall-cmd --add-forward-port=port=587:proto=tcp:toport=25 --permanent;
systemctl restart firewalld;

postal start;
