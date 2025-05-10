#!/bin/sh

set -e

read -p "Please enter domain:" domainname
read -p "Please enter Msql password: LFr37rG3r " domainpasspw

sudo apt update -y && sudo apt upgrade -y;
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

# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl git jq
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install helper
git clone https://github.com/postalserver/install /opt/postal/install
ln -s /opt/postal/install/bin/postal /usr/bin/postal


docker run -d \
   --name postal-mariadb \
   -p 0.0.0.0:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=postal \
   mariadb

docker run -d \
   --name postal-rabbitmq \
   -p 127.0.0.1:5672:5672 \
   --restart always \
   -e RABBITMQ_DEFAULT_USER=postal \
   -e RABBITMQ_DEFAULT_PASS=postal \
   -e RABBITMQ_DEFAULT_VHOST=postal \
   rabbitmq:3.8
   
postal bootstrap postal.$domainname;
  
sed -i -e '/^smtp_server:/d' /opt/postal/config/postal.yml
sed -i -e '/^  port: 25/d' /opt/postal/config/postal.yml

echo '' | sudo tee -a /opt/postal/config/postal.yml;
echo 'smtp_server:' | sudo tee -a /opt/postal/config/postal.yml;
echo '  port: 25' | sudo tee -a /opt/postal/config/postal.yml;
echo '  tls_enabled: false' | sudo tee -a /opt/postal/config/postal.yml;
echo '  # tls_certificate_path: ' | sudo tee -a /opt/postal/config/postal.yml;
echo '  # tls_private_key_path: ' | sudo tee -a /opt/postal/config/postal.yml;
echo '  proxy_protocol: false' | sudo tee -a /opt/postal/config/postal.yml;
echo '  log_connect: true' | sudo tee -a /opt/postal/config/postal.yml;
echo '  strip_received_headers: true' | sudo tee -a /opt/postal/config/postal.yml;

sed -i -e "s/example.com/$domainname/g" /opt/postal/config/postal.yml;

postal initialize;
postal make-user;


docker run -d \
   --name postal-caddy \
   --restart always \
   --network host \
   -v /opt/postal/config/Caddyfile:/etc/caddy/Caddyfile \
   -v /opt/postal/config/caddy-data:/data \
   caddy
  
#sed -i -r "s/.*tls_certificate_path.*/  tls_certificate_path: \/opt\/postal\/caddy-data\/caddy\/certificates\/acme-v02.api.letsencrypt.org-directory\/postal.$domainname\/postal.$domainname.crt/g" /opt/postal/config/postal.yml;
#sed -i -r "s/.*tls_private_key_path.*/  tls_private_key_path: \/opt\/postal\/caddy-data\/caddy\/certificates\/acme-v02.api.letsencrypt.org-directory\/postal.$domainname\/postal.$domainname.key/g" /opt/postal/config/postal.yml;

postal stop;
postal start;
pip3 install tqdm;
pip3 install request;

reboot;
