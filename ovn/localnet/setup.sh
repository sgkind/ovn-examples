#!/bin/bash

docker exec -it ovn-master /root/create_master.sh
docker exec -it ovn-gateway1 /root/create_gateway1.sh
docker exec -it ovn-gateway2 /root/create_gateway2.sh
docker exec -it ovn-worker1 /root/create_worker1.sh
docker exec -it ovn-worker2 /root/create_worker2.sh
docker exec -it ovn-outer /root/create_outer.sh