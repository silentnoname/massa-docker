# massa-docker

## How to run

```
cd massa-docker
sudo docker build -t runmassa:latest .
sudo docker run -v $HOME/massadata:/runmassa/data --name massa --restart=always  -e AUTOHEAL_CONTAINER_LABEL=all  -d
``` 
the data will save in `$HOME/massadata` folder

## How to enter massa client
`sudo docker exec -it massa bash`
`screen -Rd client`

## more
Please reference massa official guide https://docs.massa.net/en/latest/testnet/running.html




