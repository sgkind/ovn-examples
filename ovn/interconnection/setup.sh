#!/bin/bash -x

docker exec ovn-ic /root/create_ovn_ic.sh
docker exec east-ctrl  /root/create_east_ctrl.sh
docker exec east-hv1 /root/create_east_hv1.sh
docker exec west-ctrl /root/create_west_ctrl.sh
docker exec west-hv1 /root/create_west_hv1.sh
docker exec east-ic-gw1 /root/create_east_ic_gw1.sh
docker exec west-ic-gw1 /root/create_west_ic_gw1.sh