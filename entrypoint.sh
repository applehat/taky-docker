#!/bin/bash

echo "Starting REDIS..."
redis-server --daemonize yes


echo "Setting up taky environment..."

mkdir -p /takdata
mkdir -p /takdata/log
mkdir -p /takdata/ssl

touch /var/taky/taky-mgmt.sock

# check if /takdata/taky.conf exists, and if not, copy the example config file
if [ ! -f /takdata/taky.conf ]; then
    # copy files from /usr/local/tomcat/webapps/ROOT to /takdata
    cp -r /app/taky.conf.example /takdata/taky.conf
fi

echo "Getting public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Public IP address is $PUBLIC_IP, Updating taky.conf..."

# replace the public_ip value in taky.conf with the public IP address
sed -i "s/\(public_ip *= *\).*/\1$PUBLIC_IP/" /takdata/taky.conf



taky -l debug -c /takdata/taky.conf