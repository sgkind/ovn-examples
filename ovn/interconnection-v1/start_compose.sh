#!/bin/bash -x

docker network create --gateway 10.10.0.1 --subnet 10.10.0.0/24 \
    -o --mtu=1442 ovnnet_east
docker network create --gateway 10.10.1.1 --subnet 10.10.1.0/24 \
    -o --mtu=1442 ovnnet_west
docker network create --gateway 10.11.0.1 --subnet 10.11.0.0/24 \
    -o --mtu=1442 ovnnet_conn
docker-compose up --force-recreate -d