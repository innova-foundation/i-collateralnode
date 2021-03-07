#!/bin/sh
TEMP=/tmp/answer$$
whiptail --title "Innova [INN]"  --menu  "CollateralNode :" 20 0 0 1 "Install TOR Innova CollateralNode Ubuntu 16.04" 2 "Install Innova CollateralNode Ubuntu 18.04" 3 "Update Innova CollateralNode Ubuntu 16.04" 4 "Watch innovad getinfo <ctrl+c> to exit" 2>$TEMP
choice=`cat $TEMP`
case $choice in
        1)      echo 1 "Installing TOR Innova CollateralNode Ubuntu 16.04"
echo "Updating linux packages"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 14530/tcp
sudo ufw allow 14539/tcp
sudo ufw logging on
sudo ufw --force enable

echo "Installing PWGEN"
sudo apt-get install -y pwgen

echo "Installing 2G Swapfile"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Installing Dependencies"
sudo apt-get install -y git unzip build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libgmp-dev libevent-dev autogen automake  libtool

echo "Installing TOR"
sudo apt install curl gpg gnupg2 apt-utils apt-transport-https wget -y
sudo echo 'deb https://deb.torproject.org/torproject.org stretch main' | tee -a /etc/apt/sources.list.d/torproject.list
sudo echo 'deb-src https://deb.torproject.org/torproject.org stretch main' | tee -a /etc/apt/sources.list.d/torproject.list
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
sudo apt-get update
sudo apt-get -y --no-install-recommends install tor deb.torproject.org-keyring

echo "Populate Hidden Service"
echo -e "HiddenServiceDir /var/lib/tor/hidden_service01/\nHiddenServiceVersion 2\nHiddenServicePort 14530 127.0.0.1:14530\nHiddenServicePort 14539 127.0.0.1:14539" > /etc/tor/torrc

echo "Grab Onion Address"
cd ~
sudo service tor restart
sudo cat /var/lib/tor/hidden_service01/hostname > ~/onion.txt
ONION=$(head -1 onion.txt)
echo "$ONION"

echo "Downloading Innova Wallet"
wget https://github.com/innova-foundation/innova/releases/download/v4.3.8.5/innovad
cp -rf innovad /usr/bin/innovad
#tar -xvf innovad-v3.2.5-ubuntu1604.tar.gz -C /usr/local/bin
#rm innovad-v3.2.5-ubuntu1604.tar.gz

echo "Installing Innova Wallet"
git clone https://github.com/innova-foundation/innova
cd innova
#git checkout v3.4
#git pull
cd src
make -f makefile.unix
strip innovad
sudo mv ~/innova/src/innovad /usr/local/bin/innovad

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
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=14539\naddnode=37.252.70.76\naddnode=88.207.114.233\naddnode=73.27.102.84\naddnode=218.214.99.111\nrpcallowip=127.0.0.1\nexternalip=$ONION:14539\ntor=127.0.0.1:9050\ncollateralnode=1\ncollateralnodeprivkey=$COLLATERALNODEPRIVKEY" > ~/.innova/innova.conf


#echo "Get Chaindata"
#sudo apt-get -y install unzip
#cd ~/.innova
#rm -rf database txleveldb smsgDB
#wget http://d.hashbag.cc/chaindata.zip
#unzip chaindata.zip
#wget https://github.com/innova-foundation/innova/releases/download/v3.3.9.1/chaindata2022527.zip
#unzip chaindata2022527.zip

#echo "Get Peers.dat"
#wget https://github.com/innova-foundation/innova/releases/download/v3.3.7/peers.dat

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/innovad")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/innovad stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/innovad")| crontab -

echo "Starting Innova Daemon"
innovad

echo "Watch getinfo for block sync"
watch -n 10 'innovad getinfo'
                ;;
        2)      echo 2 "Installing Innova CollateralNode Ubuntu 18.04"
echo "Updating linux packages"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 14530/tcp
sudo ufw allow 14539/tcp
sudo ufw logging on
sudo ufw --force enable

echo "Installing PWGEN"
sudo apt-get install -y pwgen

echo "Installing 2G Swapfile"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Installing Dependencies"
sudo apt-get install -y git unzip build-essential libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libgmp-dev libevent-dev autogen automake  libtool

echo "Downgrade libssl-dev"
sudo apt-get install make
wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz
tar -xzvf openssl-1.0.1j.tar.gz
cd openssl-1.0.1j
./config
make depend
make
sudo make install
sudo ln -sf /usr/local/ssl/bin/openssl `which openssl`
cd ~
openssl version -v

echo "Downloading Innova Wallet"
wget https://github.com/innova-foundation/innova/releases/download/v4.3.8.5/innovad
cp -rf innovad /usr/bin/innovad
#tar -xvf innovad-v3.2.5-ubuntu1604.tar.gz -C /usr/local/bin
#rm innovad-v3.2.5-ubuntu1604.tar.gz

echo "Installing Innova Wallet"
git clone https://github.com/innova-foundation/innova
cd innova
#git checkout v3.4
#git pull
cd src
OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib make -f makefile.unix
strip innovad
sudo mv ~/innova/src/innovad /usr/local/bin/innovad

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
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=14539\naddnode=37.252.70.76\naddnode=88.207.114.233\naddnode=73.27.102.84\naddnode=218.214.99.111\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:14539\ncollateralnode=1\ncollateralnodeprivkey=$COLLATERALNODEPRIVKEY" > ~/.innova/innova.conf


#echo "Get Chaindata"
#sudo apt-get -y install unzip
#cd ~/.innova
#rm -rf database txleveldb smsgDB
#wget http://d.hashbag.cc/chaindata.zip
#unzip chaindata.zip
#wget https://github.com/innova-foundation/innova/releases/download/v3.3.9.1/chaindata2022527.zip
#unzip chaindata2022527.zip

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/innovad")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/innovad stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/innovad")| crontab -

echo "Starting Innova Daemon"
innovad

echo "Watch getinfo for block sync"
watch -n 10 'innovad getinfo'
                ;;
        3)      echo 3 "Updating Innova CollateralNode"
echo "Stop innovad"
innovad stop

cd innova
git checkout master
git pull
cd src
make -f makefile.unix
strip innovad
sudo mv ~/innova/src/innovad /usr/local/bin/innovad

echo "Start innovad"
innovad
watch -n 10 'innovad getinfo'
                ;;
        4)      echo 4 "Watch innovad getinfo"
                watch -n 10 'innovad getinfo'
                ;;
esac
echo Selected $choice
