IP=$1
PASSWORD=$2
skip=0
PATH_CLIENT=/runmassa/massa-client
PATH_NODE=/runmassa/massa-node
PATH_HOME=/runmassa/data


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
# start the node
cd $PATH_NODE
massa-node -p $PASSWORD 2>&1 | tee $PATH_HOME/nodelogs.txt




