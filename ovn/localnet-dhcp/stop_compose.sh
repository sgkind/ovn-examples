#!/bin/bash -x

docker-compose down

docker network rm ovnnet_local
docker network rm ovnnet_outer