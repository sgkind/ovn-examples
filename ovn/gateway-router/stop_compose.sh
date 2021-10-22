#!/bin/bash

containers=(ovn-master ovn-worker1 ovn-worker2 ovn-gateway)

for container in ${containers[@]};do
    docker stop $container
    docker rm $container
done

docker network rm ovnnet_local
docker network rm ovnnet_outer
