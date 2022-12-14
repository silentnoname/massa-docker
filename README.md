# Massa-docker

## How to run

```
git clone https://github.com/silentnoname/massa-docker.git
cd massa-docker
sudo docker build -t runmassa:latest .
sudo docker run -d -v $HOME/massadata:/runmassa/data --name massa --restart=always  -e AUTOHEAL_CONTAINER_LABEL=all   runmassa:latest
``` 
the data will save in `$HOME/massadata` folder

## How to enter massa client
```
sudo docker exec -it massa bash
screen -Rd client
```

## How to join the testnet
1. Join massa discord https://discord.gg/massa
2. Send your address in #testnet-faucet channel.(open massa client, enter `wallet_info` to get your address)
3. After get the token,enter `buy_rolls <address> 1 0` 
4. Send anything in #testnet-rewards-registration channel,check dm.
5. Follow the instruction from the Massabot. Send your IP address for routable score. 


## More
Please refer massa official guide https://docs.massa.net/en/latest/testnet/running.html




