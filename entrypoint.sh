#!/bin/bash

echo "Setting up taky environment..."

sudo mkdir -p /takdata/log
sudo mkdir -p /takdata/ssl

# check if /takdata/taky.conf exists, and if not, copy the example config file
if [ ! -f /takdata/taky.conf ]; then
    cp -r /app/taky.conf.example /takdata/taky.conf
fi

# check /takdata/taky.conf for the REDIS value
REDIS=$(grep redis /takdata/taky.conf)
if [[ "$REDIS" == *"True"* ]]; then
  echo "Starting internal redis server..."
  redis-server --daemonize yes
else 
  echo "Internal redis server disabled. $redis"
fi

echo "Getting public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)

echo "Public IP address is $PUBLIC_IP, Updating taky.conf..."
# replace the public_ip value in taky.conf with the public IP address
sed -i "s/\(public_ip *= *\).*/\1$PUBLIC_IP/" /takdata/taky.conf

taky -l debug -c /takdata/taky.conf