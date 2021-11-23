#!/bin/bash -x

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=random
/usr/share/ovn/scripts/ovn-ctl start_controller

ovs-vsctl add-br br-int -- set Bridge br-int fail-mode=secure

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:$OVN_SERVER:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$MY_IP

/usr/share/ovn/scripts/ovn-ctl stop_controller
/usr/share/ovn/scripts/ovn-ctl start_controller

function add_vm5() {
    ip netns add vm5 
    ovs-vsctl add-port br-int vm5 -- set interface vm5 type=internal
    ip link set vm5 netns vm5 
    ip netns exec vm5 ip link set vm5 address 00:00:01:01:02:14
    ip netns exec vm5 ip addr add 192.168.1.20/24 dev vm5
    ip netns exec vm5 ip link set vm5 up
    ip netns exec vm5 ip route add default via 192.168.1.1
    ovs-vsctl set Interface vm5 external_ids:iface-id=vm5
}

function add_vm6() {
    ip netns add vm6 
    ovs-vsctl add-port br-int vm6 -- set interface vm6 type=internal
    ip link set vm6 netns vm6
    ip netns exec vm6 ip link set vm6 address 00:00:01:01:02:15
    ip netns exec vm6 ip addr add 192.168.2.20/24 dev vm6
    ip netns exec vm6 ip link set vm6 up
    ip netns exec vm6 ip route add default via 192.168.2.1
    ovs-vsctl set Interface vm6 external_ids:iface-id=vm6
}

add_vm5
add_vm6

ovs-vsctl --may-exist add-br br-ext
ovs-vsctl br-set-external-id br-ext bridge-id br-ext
ovs-vsctl add-port br-ext eth1

ovs-vsctl set open . external-ids:ovn-bridge-mappings=ext:br-ext
ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="ext:aa:bb:cc:dd:ee:22"