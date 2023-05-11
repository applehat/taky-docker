FROM python:3.11.3

# Initial setup for adding a non-root user
RUN apt-get update && \
      apt-get -y install sudo lsb-release crudini certbot

RUN adduser --disabled-password --gecos '' takuser
RUN adduser takuser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER takuser

# install redis
RUN curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
RUN sudo apt-get update && sudo apt-get install -y redis

WORKDIR /app

ADD entrypoint.sh /app/entrypoint.sh
ADD taky.conf /app/taky.conf.example
ADD certbot.conf /app/certbot.conf.example
RUN sudo chmod +x /app/entrypoint.sh

RUN sudo python3 -m pip install --upgrade pip
RUN sudo python3 -m pip install taky

ARG TAKY_CONFIG
ENV TAKY_CONFIG=TAKY_CONFIG

ARG TAKY_LOG
ENV TAKY_LOG=TAKY_LOG

ENTRYPOINT ["/app/entrypoint.sh"]
