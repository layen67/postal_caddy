apt update;
apt install git curl jq;
git clone https://postalserver.io/start/install /opt/postal/install;
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal;
apt-get update;apt-get install -y docker.io;
curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose;chmod +x /usr/local/bin/docker-compose;
docker run -d \ --name postal-mariadb \ -p 127.0.0.1:3306:3306 \ --restart always \ -e MARIADB_DATABASE=postal \ -e MARIADB_ROOT_PASSWORD=postal \ mariadb;
docker run -d \ --name postal-rabbitmq \ -p 127.0.0.1:5672:5672 \ --restart always \ -e RABBITMQ_DEFAULT_USER=postal \ -e RABBITMQ_DEFAULT_PASS=postal \ -e RABBITMQ_DEFAULT_VHOST=postal \ rabbitmq:3.8
