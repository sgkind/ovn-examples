#!/bin/bash -x

start-ovs
start-ovn-controller

ovs-vsctl --may-exist add-br br-int  \
    -- set Bridge br-int fail-mode=secure

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:system-id=east-ic-gw1
ovs-vsctl set open . external-ids:ovn-remote=tcp:10.10.0.2:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=10.10.0.4

ovs-vsctl set open_vswitch . external_ids:ovn-is-interconn=true
