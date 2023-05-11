#!/bin/bash

echo "Setting up taky environment..."

sudo mkdir -p /takdata/log
sudo mkdir -p /takdata/ssl
sudo chmod -R 777 /takdata

# check if /takdata/taky.conf exists, and if not, copy the example config file
if [ ! -f /takdata/taky.conf ]; then
    sudo cp -r /app/taky.conf.example /takdata/taky.conf
fi

# check if /takdata/taky.conf exists, and if not, copy the example config file
if [ ! -f /takdata/certbot.conf ]; then
    sudo cp -r /app/certbot.conf.example /takdata/certbot.conf
fi

echo "Checking configuration for internal redis server..."

# check /takdata/taky.conf for the REDIS value
REDIS=$(crudini --get /takdata/taky.conf taky redis)
if [[ "$REDIS" == *"True"* ]]; then
  sudo mkdir -p /takdata/redis
  echo "Starting internal redis server..."
  redis-server --daemonize yes --dir /takdata/redis
else 
  echo "Internal redis server disabled. $redis"
fi

echo "Getting public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)

echo "Public IP address is $PUBLIC_IP, Updating taky.conf..."
# replace the public_ip value in taky.conf with the public IP address
crudini --set /takdata/taky.conf taky public_ip $PUBLIC_IP

echo "Checking certbot configuration..."
CERTBOT_ENABLED=$(crudini --get /takdata/certbot.conf certbot enabled)
CERTBOT_EMAIL=$(crudini --get /takdata/certbot.conf certbot email)
CERTBOT_DOMAIN=$(crudini --get /takdata/taky.conf taky hostname)
if [[ "$CERTBOT_ENABLED" == *"true"* ]]; then
  # if /takdata/ssl/fullchain.pem exists, then certbot has already been run
  if [ -f /takdata/ssl/fullchain.pem ]; then
    echo "Certbot has already been run the first time. Renewing certbot for $CERTBOT_DOMAIN..."
    sudo mkdir -p /etc/letsencrypt/live/$CERTBOT_DOMAIN
    sudo cp /takdata/ssl/fullchain.pem /etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem
    sudo cp /takdata/ssl/privkey.pem /etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem
    sudo certbot renew
    sudo cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem /takdata/ssl/fullchain.pem
    sudo cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem /takdata/ssl/privkey.pem
  else
    echo "Certbot enabled, starting certbot for $CERTBOT_DOMAIN..."
    sudo certbot certonly --standalone -n --agree-tos --email $CERTBOT_EMAIL -d $CERTBOT_DOMAIN
    sudo cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem /takdata/ssl/fullchain.pem
    sudo cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem /takdata/ssl/privkey.pem
  fi

  # Download the letsencryptauthorityx3.pem file if it doesn't exist in /takdata/ssl
  if [ ! -f /takdata/ssl/letsencryptauthorityx3.pem ]; then
    echo "Downloading letsencryptauthorityx3.pem..."
    sudo wget "https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt" --output-document=/takdata/ssl/letsencryptauthorityx3.pem
  fi

  echo "Enabling SSL in taky.conf..."

  # Enable SSL in taky.conf
  crudini --set /takdata/taky.conf ssl enabled True
  crudini --set /takdata/taky.conf ssl cert /takdata/ssl/fullchain.pem
  crudini --set /takdata/taky.conf ssl key /takdata/ssl/privkey.pem
  crudini --set /takdata/taky.conf ssl ca /takdata/ssl/letsencryptauthorityx3.pem
else 
  echo "Certbot disabled. Disabling SSL in taky.conf..."
  # Disable SSL in taky.conf
  crudini --set /takdata/taky.conf ssl enabled False
fi


taky -l debug -c /takdata/taky.conf