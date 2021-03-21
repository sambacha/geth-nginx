# [geth-nginx](#)

![](./docker/pagespeed.png)

## go-ethereum mode

A small NGINX recipe that makes Geth’s RPC and Websocket interface remotely accessible on a node. With this config RPC becomes remotely accessible at http://{SERVER_IP}/rpc and websockets at http://{SERVER_IP}/ws.

First start and sync a node on the device with the RPC and websocket endpoints opened, you can use the following command:

```bash
./geth --cache 4096 --rpc --rpcaddr "127.0.0.1" --rpccorsdomain "*" --rpcport "8545" --rpcapi "db, eth, net, web3, personal" --ws --wsport 8546 --wsaddr "127.0.0.1" --wsorigins "*" --wsapi "web3, eth" --maxpeers=100
```

> see more details in the `/geth` directory


## Install

```bash
#!/bin/bash
#Navigate to your NGINX configuration directory on your server:
cd /etc/nginx

#Create a backup of your current NGINX configuration:
tar -czvf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/

#Extract the new compressed configuration archive using tar:
tar -xzvf nginxconfig.io-backbonecabal.net.tar.gz

#Create a common ACME-challenge directory (for Let's Encrypt):
mkdir -p /var/www/_letsencrypt
chown nginx /var/www/_letsencrypt

#Comment out SSL related directives in the configuration:

sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/backbonecabal.net.conf
#Reload your NGINX server:

sudo nginx -t && sudo systemctl reload nginx
#Obtain SSL certificates from Let's Encrypt using Certbot:

certbot certonly --webroot -d backbonecabal.net -d www.backbonecabal.net -d cdn.backbonecabal.net --email admin@backbonecabal.net -w /var/www/_letsencrypt -n --agree-tos --force-renewal
#Uncomment SSL related directives in the configuration:

sed -i -r 's/#?;#//g' /etc/nginx/sites-available/backbonecabal.net.conf
#Reload your NGINX server:

sudo nginx -t && sudo systemctl reload nginx
#Configure Certbot to reload NGINX when it successfully renews certificates:
echo -e '#!/bin/bash\nnginx -t && systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh
sudo nginx -t && sudo systemctl reload nginx
```
