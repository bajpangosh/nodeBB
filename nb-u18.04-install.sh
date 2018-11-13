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
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
# Create administrative user
echo "Creating user: \"$DBUSER\"..."
PASS1=`pwgen -s -1 16`
mongo admin --eval "db.createUser( { user: "admin", pwd: "$PASS1", roles: [ { role: "readWriteAnyDatabase", db: "admin" }, { role: "userAdminAnyDatabase", db: "admin" } ] } );"
PASS2=`pwgen -s -1 16`
mongo $DBUSER --eval "db.createUser( { user: "$DBUSER", pwd: "$PASS2", roles: [ { role: "readWrite", db: "$DBUSER" }, { role: "clusterMonitor", db: "admin" } ] } );"
quit()
sudo systemctl restart mongod
echo "========================================================================"
echo "MongoDB User: \"$DBUSER\""
echo "MongoDB Password: \"$PASS2\""
echo "MongoDB Database: \"$DBUSER\""
echo "========================================================================"
git clone -b v1.10.x https://github.com/NodeBB/NodeBB.git nodebb
cd nodebb
./nodebb setup
./nodebb start
