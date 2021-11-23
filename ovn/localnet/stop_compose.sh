#!/bin/bash

containers=(ovn-master ovn-gateway1 ovn-gateway2 ovn-worker1 ovn-worker2 ovn-outer)

for container in ${containers[@]};do
    docker stop $container
    docker rm $container
done

docker network rm ovnnet_local
docker network rm ovnnet_outer
