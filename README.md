# Massa-docker
## How to update from old testnet
```
cd $HOME
sudo docker stop massa
sudo docker rm massa
sudo rm -rf $HOME/massadata
sudo rm -rf massa-docker
```
and follow the step below, no date need to save (the score is linked to discord account)

## Upgrade from old version
```
sudo docker stop massa
sudo docker rm massa
cd $HOME/massa-docker
git pull
sudo docker build -t runmassa:latest .
sudo docker stop autoheal
sudo docker rm autoheal
sudo docker run -d --name autoheal \
  --restart=always \
  -e AUTOHEAL_CONTAINER_LABEL=all \
  -v /var/run/docker.sock:/var/run/docker.sock \
  willfarrell/autoheal
sudo docker run -d -v $HOME/massadata:/runmassa/data --name massa --restart=always  -p 31244-31245:31244-31245 -e AUTOHEAL_CONTAINER_LABEL=all   runmassa:latest
```


## How to run

```
git clone https://github.com/silentnoname/massa-docker.git
cd massa-docker
sudo docker build -t runmassa:latest .
sudo docker stop autoheal
sudo docker rm autoheal
sudo docker run -d --name autoheal \
  --restart=always \
  -e AUTOHEAL_CONTAINER_LABEL=all \
  -v /var/run/docker.sock:/var/run/docker.sock \
  willfarrell/autoheal
sudo docker run -d -v $HOME/massadata:/runmassa/data --name massa --restart=always  -p 31244-31245:31244-31245  -e AUTOHEAL_CONTAINER_LABEL=all   runmassa:latest
``` 
the data will save in `$HOME/massadata` folder

## How to enter massa client
```
sudo docker exec -it massa bash
cd massa-client
./massa-client -p password
```

## How to join the testnet
1. Join massa discord https://discord.gg/massa
2. Send your address in #testnet-faucet channel.(open massa client, enter `wallet_info` to get your address)
3. After get the token,enter `buy_rolls <address> 1 0` 
4. run `node_start_staking <address>`
5. Send anything in #testnet-rewards-registration channel,check dm.
6. Follow the instruction from the Massabot. Send your IP address for routable score. 


## More
Please refer massa official guide https://docs.massa.net/en/latest/testnet/running.html




