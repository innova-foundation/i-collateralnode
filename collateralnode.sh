#!/bin/bash

echo "Updating linux packages"
sudo apt-get update -y && apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
ufw default allow outgoing
ufw default deny incoming
ufw allow ssh/tcp
ufw limit ssh/tcp
ufw allow 14530/tcp
ufw allow 14539/tcp
ufw logging on
ufw --force enable

echo "Installing PWGEN"
sudo apt-get install -y pwgen

echo "Installing 2G Swapfile"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Installing Dependencies"
sudo apt-get --assume-yes install git unzip build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libgmp-dev libevent-dev autogen automake  libtool

echo "Downloading Innova Wallet"
wget https://github.com/innova-foundation/innova/releases/download/v4.3.8.9/innovad
cp -rf innovad /usr/bin/innovad

echo "Installing Innova Wallet"
git clone https://github.com/innova-foundation/innova
cd innova
git checkout master
git pull
cd src
make -f makefile.unix
mv ~/innova/src/innovad /usr/local/bin/innovad

echo "Populate innova.conf"
mkdir ~/.innova
    # Get VPS IP Address
    VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)
    echo -n "What is your collateralnodeprivkey? (Hint:genkey output)"
    read COLLATERALNODEPRIVKEY
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=14539\naddnode=innseeder.circuitbreaker.online\naddnodeinnseeder.circuitbreaker.dev\naddnode=innseeder.innovai.cloud\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:14539\ncollateralnode=1\ncollateralnodeprivkey=$COLLATERALNODEPRIVKEY" > ~/.innova/innova.conf


#echo "Get Chaindata"
#sudo apt-get -y install unzip
#cd ~/.innova
#rm -rf database txleveldb smsgDB
#wget https://github.com/innova-foundation/innova/releases/download/v4.3.8.8/innovabootstrap.zip
#unzip innovabootstrap.zip
#rm innovabootstrap.zip

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/innovad")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/innovad stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/innovad")| crontab -

echo "Starting Innova Daemon"
innovad

echo "Watch getinfo for block sync"
watch -n 10 'innovad getinfo'
