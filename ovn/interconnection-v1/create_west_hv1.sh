#!/bin/bash -x

start-ovs
start-ovn-controller 

function add_vm1() {
    ovs-vsctl add-port br-int vm1 -- set interface vm1 type=internal
    ip link set vm1 address 00:00:02:01:02:0a
    ip netns add vm1
    ip link set vm1 netns vm1
    ip netns exec vm1 ip addr add 192.168.2.2/24 dev vm1
    ip netns exec vm1 ip link set vm1 up
    ip netns exec vm1 ip route add default via 192.168.2.1
    ovs-vsctl set Interface vm1 external_ids:iface-id=vm1
}

ovs-vsctl --may-exist add-br br-int \
    -- set Bridge br-int fail-mode=secure

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:10.10.1.2:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=10.10.1.3

add_vm1 