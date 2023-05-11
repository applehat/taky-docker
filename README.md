# Taky Docker

This exists as a simple way of getting a Taky up and running quickly in a docker container.

I created it for use with Unraid.

## Usage

```
docker run --rm -it -v $(shell pwd)/takdata:/takdata -p 8087:8087 -p 8089:8089 applehat/taky:latest
```

You essentially need to expose the ports for the TAK server to work, and mount a volume for the data to persist.

The default taky.conf that is generated will write to /takdata/taky.conf, so you can mount that directory to your host machine to persist the config.

## SSL

`certbot` is included. After your first run, you can edit `taky.conf` and set a URL for the `hostname`

```ini
[taky]
# System hostname
hostname=sometakdomain.com
# ...
```
The, you can edit `cartbot.conf` and add an email address, and enable certbot.
```ini
[certbot]
enabled=true
email=foo@bar.com
```

Then, next time you start the container, it will generate a certificate for you and enable it in the taky.conf file.

Please note you will need to make sure that port 80 of your container is open, and that your domain points to it.