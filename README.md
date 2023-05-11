# Taky Docker

This exists as a simple way of getting a Taky up and running quickly in a docker container.

I created it for use with Unraid.

## Usage

```
docker run --rm -it -v $(shell pwd)/takdata:/takdata -p 8087:8087 -p 8089:8089 applehat/taky:latest
```

You essentially need to expose the ports for the TAK server to work, and mount a volume for the data to persist.

The default taky.conf that is generated will write to /takdata/taky.conf, so you can mount that directory to your host machine to persist the config.