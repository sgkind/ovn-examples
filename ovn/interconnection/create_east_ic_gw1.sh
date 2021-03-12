#!/bin/bash -x

start-ovs
start-ovn-controller

ovs-vsctl --may-exist add-br br-int  \
    -- set Bridge br-int fail-mode=secure

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:system-id=east-ic-gw1
ovs-vsctl set open . external-ids:ovn-remote=tcp:$OVN_SERVER:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$MY_IP

#ovs-vsctl --may-exist add-br br-ex
#ovs-vsctl br-set-external-id br-ex bridge-id br-ex
#ovs-vsctl br-set-external-id br-int bridge-id br-int
#ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex
#ovs-vsctl add-port br-ex eth0

ovs-vsctl set open_vswitch . external_ids:ovn-is-interconn=true
