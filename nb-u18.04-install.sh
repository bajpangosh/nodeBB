#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. database name)?"
read DBUSER
echo "Updating OS................."
sleep 2;
sudo apt-get update
sudo apt-get install nginx git zip unzip pwgen -y
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update

echo "Sit back and relax :) ......"
sleep 2;
cd /etc/nginx/sites-available/
sudo wget -O "$DOMAIN" https://goo.gl/XYY7Hb
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -O nginx.conf https://goo.gl/7UBeQS
sudo mkdir /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
echo "Creating Admin for MongoDB................."
sleep 2;
PASS1=`pwgen -s 14 1`
mongo admin --eval "db.createUser( { user: 'admin', pwd: '$PASS1', roles: [ { role: 'readWriteAnyDatabase', db: 'admin' }, { role: 'userAdminAnyDatabase', db: 'admin' } ] } );"
echo "Creating user: \"$DBUSER\"..."
sleep 2;
PASS2=`pwgen -s 14 1`
mongo $DBUSER --eval "db.createUser( { user: '$DBUSER', pwd: '$PASS2', roles: [ { role: 'readWrite', db: '$DBUSER' }, { role: 'clusterMonitor', db: 'admin' } ] } );"
echo "MongoDB Successfully created..............."
sleep 2;
echo "========================================================================"
echo "MongoDB User: \"$DBUSER\""
echo "MongoDB Password: \"$PASS2\""
echo "MongoDB Database: \"$DBUSER\""
echo "========================================================================"
sudo systemctl restart mongod
git clone -b v1.10.x https://github.com/NodeBB/NodeBB.git nodebb
cd nodebb
./nodebb setup
./nodebb start
