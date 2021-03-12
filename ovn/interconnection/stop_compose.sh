#!/bin/bash -x

docker-compose down

docker network rm ovnnet_east
docker network rm ovnnet_west
docker network rm ovnnet_conn