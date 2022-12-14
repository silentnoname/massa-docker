IP=$1
PASSWORD=$2
skip=0
PATH_CLIENT=/runmassa/massa-client
PATH_NODE=/runmassa/massa-node
PATH_HOME=/runmassa/data


Backupwallet() {
        # Backup wallet
        cd $PATH_CLIENT
        if [ ! -f $PATH_HOME/wallet.dat ]; then
            cp wallet.dat $PATH_HOME/wallet.dat
        fi
}

# check if config/config.toml  file exists,if exists ,skip
if [ -f "$PATH_NODE/config/config.toml" ]; then
    echo "$PATH_NODE/config/config.toml exists, skip"
    skip=1
fi
if [ $skip -eq 0 ]; then
    #if no ip input, get ip from curl
    if [ "$IP" = "none" ]; then
        IP=$(curl -s curl ifconfig.me)
    fi
    chmod o+w $PATH_NODE/config/
    tee $PATH_NODE/config/config.toml  > /dev/null <<EOF
    [network]
    routable_ip = "${IP}"
EOF
fi
echo $PASSWORD >>$PATH_HOME/password.txt
# Create wallet and backup
clientPID=$(ps -ax | grep client | grep SCREEN | awk '{print $1}')
#if cliend pid is not empty
if [ -n "$clientPID" ]; then
	echo "Client is running"
	#kill client
	kill -9 $clientPID
fi
cd $PATH_CLIENT
screen -dmS client massa-client -p $PASSWORD
sleep 10
Backupwallet
# start the node
cd $PATH_NODE
massa-node -p $PASSWORD 2>&1 | tee $PATH_HOME/nodelogs.txt


