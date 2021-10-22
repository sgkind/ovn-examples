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

function add_vm2() {
    ip netns add vm2
    ovs-vsctl add-port br-int ens3 -- set interface ens3 type=internal
    ip link set ens3 netns vm2
    ip netns exec vm2 ip link set ens3 address 0a:58:0a:f4:01:02
    ip netns exec vm2 ip addr add 10.244.1.2/24 dev ens3
    ip netns exec vm2 ip link set ens3 up
    ip netns exec vm2 ip route add default via 10.244.1.1
    ovs-vsctl set Interface ens3 external_ids:iface-id=default-vm2
}

add_vm2
