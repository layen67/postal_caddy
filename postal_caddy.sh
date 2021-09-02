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
apt-get install -y python3-click python-click;


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
    name: rp.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: spf.postal
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: track.postal
    
  # the following will update your subdomain's A record with your current ip (v4)
  - domain: $domainname
    name: belgium
    type: CNAME
    target: news.oued-laou.com # you can omit this line
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
    name: POSTAL-RO9MOV._DOMAINKEY
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
"> /etc/freenom.yml;
fdu process -c -i -t 3600 /etc/freenom.yml&

sleep 500

fdu process -c -i -t 3600 /etc/freenom.yml&

apt update;
apt install git curl jq;
git clone https://postalserver.io/start/install /opt/postal/install;
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal;
apt-get update;apt-get install -y docker.io;
curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose;chmod +x /usr/local/bin/docker-compose;
docker run -d \ --name postal-mariadb \ -p 127.0.0.1:3306:3306 \ --restart always \ -e MARIADB_DATABASE=postal \ -e MARIADB_ROOT_PASSWORD=postal \ mariadb;
docker run -d \ --name postal-rabbitmq \ -p 127.0.0.1:5672:5672 \ --restart always \ -e RABBITMQ_DEFAULT_USER=postal \ -e RABBITMQ_DEFAULT_PASS=postal \ -e RABBITMQ_DEFAULT_VHOST=postal \ rabbitmq:3.8
