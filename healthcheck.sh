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

Backupwallet() {
        # Backup wallet
        cd $PATH_CLIENT
        if [ ! -f $PATH_HOME/wallet.dat ]; then
            cp wallet.dat $PATH_HOME/wallet.dat
        fi
}

CreateWalletAndBackup() {
	## Create a wallet, stake and backup
	# If wallet don't exist
	cd $PATH_CLIENT
	checkWallet=`massa-client -p $PASSWORD wallet_info | grep -c "Secret key"`
	if ([ ! -e $PATH_CLIENT/wallet.dat ] || [ $checkWallet -lt 1 ])
	then
		# Generate wallet
		cd $PATH_CLIENT
		massa-client -p $PASSWORD wallet_generate_secret_key > /dev/null
                sleep 10
		if [ ! -f $PATH_HOME/wallet.dat ]; then
                        cp wallet.dat $PATH_HOME/wallet.dat
                        screen -dmS client bash -c 'massa-client -p '$PASSWORD''
                        echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Backup wallet.dat to $PATH_HOME" >>$PATH_HOME/healthcheck.txt
                fi
	fi
	# If staking_keys don't exist
        cd $PATH_CLIENT
	checkStackingKey=`massa-client -p $PASSWORD node_get_staking_addresses | grep -c -E "[0-z]{51}"`
	if ([ ! -e $PATH_NODE/config/staking_wallet.dat ] || [ $checkStackingKey -lt 1 ])
	then
		# Get private key
		cd $PATH_CLIENT
		privKey=$(massa-client -p $PASSWORD wallet_info | grep "Secret key" | cut -d " " -f 3)
		# Stake wallet
		massa-client -p $PASSWORD node_add_staking_secret_keys $privKey > /dev/null
		# Backup staking_wallet.dat 
                if [ ! -e $PATH_HOME/staking_wallet.dat ]
                then
		        cp $PATH_NODE/config/staking_wallet.dat $PATH_HOME/staking_wallet.dat
		        echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Backup staking_wallet.dat to $PATH_HOME" >>$PATH_HOME/healthcheck.txt
                fi
	fi

        #backup  node_privkey.key
        if [ ! -e $PATH_HOME/node_privkey.key ]
	then
		# Copy node_privkey.key to $PATH_HOME
		cp $PATH_NODE/config/node_privkey.key $PATH_HOME/node_privkey.key
		echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Backup node_privkey.key to $PATH_HOME" >>$PATH_HOME/healthcheck.txt
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
        CreateWalletAndBackup
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
