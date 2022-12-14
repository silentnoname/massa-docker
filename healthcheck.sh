PATH_HOME=/runmassa/data
PATH_CLIENT=/runmassa/massa-client
PATH_NODE=/runmassa/massa-node
PASSWORD=$1

WaitBootstrap() {
        # Wait node booststrap
        # if node is still bootstrapping, return 1
        bootstrapmsg=$(tail -n +1 $PATH_HOME/nodelogs.txt | grep -m 1 -E "Successful bootstrap"\|"seconds remaining to genesis")
        if [ -z "$bootstrapmsg" ]
        then
                echo 1
        else
                echo 0
        fi
}

CheckNodeHealth() {
        # Check node status and logs events
    # If node is still bootstrapping, ruturn 0
    Bootstrapped=$(WaitBootstrap)
    if [ $Bootstrapped  -eq 1 ]
        then
                echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Node is still bootstrapping" >>$PATH_HOME/healthcheck.txt
                exit 0
        fi
        #backup  node_privkey.key
        if [ ! -e $PATH_HOME/node_privkey.key ]
	then
		# Copy node_privkey.key to $PATH_HOME
		cp $PATH_NODE/config/node_privkey.key $PATH_HOME/node_privkey.key
		echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )]Backup node_privkey.key to $PATH_HOME" >>$PATH_HOME/healthcheck.txt
	fi
        cd $PATH_CLIENT
        checkGetStatus=$(timeout 2 massa-client -p $PASSWORD get_status | wc -l)

        # If get_status is responsive
        if [ $checkGetStatus -lt 10 ]
        then
                echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours")] Node is unhealthy, restarting">>$PATH_HOME/healthcheck.txt
                exit  1
        # If get_status hang
        else
                exit 0
        fi
}

CheckNodeHealth
