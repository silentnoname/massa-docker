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
	checkWallet=`massa-client -p $PASSWORD wallet_info | grep -c "Address:"`
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
        #backup  node_privkey.key
        if [ ! -e $PATH_HOME/node_privkey.key ]
	then
		# Copy node_privkey.key to $PATH_HOME
		cp $PATH_NODE/config/node_privkey.key $PATH_HOME/node_privkey.key
		echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Backup node_privkey.key to $PATH_HOME" >>$PATH_HOME/healthcheck.txt
	fi
}

#############################################################
# FONCTION = GetCandidateRoll
# DESCRIPTION = Ckeck candidate roll on node
# RETURN = Candidate rolls amount
#############################################################
GetCandidateRoll() {
	$PATH_CLIENT/massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.candidate_rolls'
}

#############################################################
# FONCTION = GetRollBalance
# DESCRIPTION = Ckeck final roll on node
# RETURN = final rolls amount
#############################################################
GetRollBalance() {
	$PATH_CLIENT/massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.final_rolls'
}

#############################################################
# FONCTION = GetActiveRolls
# DESCRIPTION = Ckeck active roll on node
# RETURN = active rolls amount
#############################################################
GetActiveRolls() {
	$PATH_CLIENT/massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.active_rolls'
}

#############################################################
# FONCTION = GetMASAmount
# DESCRIPTION = Check MAS amount on active wallet
# RETURN = MAS amount
#############################################################
GetMASAmount() {
	$PATH_CLIENT/massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.final_balance'
}


AutoBuyRoll(){
        cd $PATH_CLIENT
	address=$(massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.address')
        # Get rolls
	CandidateRolls=$(($(GetCandidateRoll $WalletAddress)))
	ActiveRolls=$(($(GetActiveRolls $WalletAddress)))
	Rolls=$(($(GetRollBalance $WalletAddress)))

	# Get MAS amount and keep integer part
	MasBalance=$(GetMASAmount $WalletAddress)
	MasBalanceInt=$(echo $MasBalance | awk -F '.' '{print $1}')
	MasBalanceInt="${MasBalanceInt:-0}"
        ROLL_COST=100
        echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Rolls: Candidate: $CandidateRolls, Final: $Rolls, Active: $ActiveRolls, Target: $targetRollAmount" >>$PATH_HOME/healthcheck.txt
	
        function buy_rolls {
		local rolls_to_buy=$1
                echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Buying $rolls_to_buy roll(s)..." >>$PATH_HOME/healthcheck.txt
		massa-client -p $PASSWORD buy_rolls $WalletAddress $rolls_to_buy 0 > /dev/null
	}

	# Buy as many rolls as possible with available balance
	if (( $MasBalanceInt >= $ROLL_COST )); then
		rolls_to_buy=$(($MasBalanceInt / $ROLL_COST))
		buy_rolls $rolls_to_buy
	else
		if (( $CandidateRolls == 0 )) && (( $ActiveRolls == 0 )); then
                        echo "[$(date +"%Y-%m-%d %H:%M:%S" --utc -d "+8 hours" )] Insuficient MAS balance to buy first ROLL. (current balance is $MasBalance MAS)" >>$PATH_HOME/healthcheck.txt
	
                fi

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
                AutoBuyRoll
                exit 0
        fi
}



CheckNodeHealth
