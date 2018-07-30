
echo "=================================================================="
echo "NodeCircle MN Install"
echo "=================================================================="

echo -n "Installing pwgen..."
sudo apt-get install -y pwgen

echo -n "Installing dns utils..."
sudo apt-get install -y dnsutils

PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)
WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

#begin optional swap section
echo "Setting up disk swap..."
free -h
sudo fallocate -l 4G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab sudo bash -c "
echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
free -h
echo "SWAP setup complete..."
#end optional swap section

echo "Installing packages and updates..."

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get install build-essential libtool automake autoconf -y
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -y
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libdb5.3-dev libdb5.3++-dev -y

echo "Packages complete..."

cd ~
rm -rdf nodecircle
mkdir nodecircle
cd nodecircle
rm -rdf nodecircle-1.0.0
rm -rf nodecircle-1.0.0-x86_64-linux-gnu.tar.gz
wget https://github.com/nodecircle/NodeCircle/releases/download/v1.0.0/nodecircle-1.0.0-x86_64-linux-gnu.tar.gz

mkdir nodecircle-1.0.0
tar -zxvf nodecircle-1.0.0-x86_64-linux-gnu.tar.gz
sudo rm -rf /usr/local/bin/nodecircle-cli
sudo rm -rf /usr/local/bin/nodecircled
sudo cp nodecircle-1.0.0/bin/nodecircle-cli /usr/local/bin/
sudo cp nodecircle-1.0.0/bin/nodecircled /usr/local/bin/


nodecircle-cli stop
sleep 20


rm -rdf /root/.nodecircle
mkdir /root/.nodecircle

cat <<EOF > ~/.nodecircle/nodecircle.conf
rpcuser=nodecircle
rpcpassword=3a76std7sa6da8sfd8
EOF

echo "LOADING WALLET..."
nodecircled --daemon
sleep 30

echo "making genkey..."
GENKEY=$(nodecircle-cli masternode genkey)

nodecircle-cli stop
sleep 30

echo "creating final config..."

cat <<EOF > ~/.nodecircle/nodecircle.conf

rpcuser=NodeCircle
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
listenonion=0
listen=1
staking=0
port=18775
masternode=1
masternodeprivkey=$GENKEY

EOF

echo "LOADING WALLET..."
nodecircled --daemon
sleep 30


echo "mining info..."
nodecircle-cli getmininginfo
nodecircle-cli stop


echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#add a firewall
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 18775/tcp
sudo ufw logging on
sudo ufw status
echo y | sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
nodecircled --daemon
sleep 30


crontab -l > cronconfig
#echo new cron into cron file
echo "* * * * * nodecircled --daemon >/dev/null 2>&1" >> cronconfig
#install new cron file
crontab cronconfig
rm cronconfig

echo "nodecircle-cli getmininginfo:"
nodecircle-cli getmininginfo

echo "masternode status:"
echo "nodecircle-cli masternode status"
nodecircle-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP:18775"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
sleep 1
echo "rpcuser=NodeCircle\nrpcpassword=$PASSWORD"
