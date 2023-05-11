build: 
	DOCKER_BUILDKIT=1 docker build \
					--platform linux/amd64 \
					-f Dockerfile \
					-t applehat/taky \
					.

up-test:: ## start last build of engine in the test framework
	docker run --rm -it -v $(shell pwd)/takdata:/takdata -p 8087:8087 -p 8089:8089 -p 80:80 applehat/taky:latest


push: 
	docker push applehat/taky:latest

deploy: build push