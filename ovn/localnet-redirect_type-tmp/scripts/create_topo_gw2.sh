#!/bin/bash -x

start-ovs
start-ovn-controller

ovs-vsctl add-br br-int -- set Bridge br-int fail-mode=secure
ovs-vsctl br-set-external-id br-int bridge-id br-int

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:$OVN_SERVER:6642
ovs-vsctl set open . external-ids:system-id=gw2
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$MY_IP

stop-ovn-controller
start-ovn-controller

ovs-vsctl --may-exist add-br br-ext
ovs-vsctl br-set-external-id br-ext bridge-id br-ext
ovs-vsctl add-port br-ext eth1

ovs-vsctl --may-exist add-br br-ext1
ovs-vsctl br-set-external-id br-ext1 bridge-id br-ext1
ovs-vsctl add-port br-ext1 eth2

ovs-vsctl set open . external-ids:ovn-bridge-mappings=ext:br-ext,ext1:br-ext1

#ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="ext1:aa:bb:cc:dd:ee:44,ext:aa:bb:cc:dd:ee:66"