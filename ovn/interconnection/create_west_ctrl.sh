#!/bin/bash -x

start-ovn-northd

ovn-nbctl set-connection ptcp:6641:0.0.0.0
ovn-sbctl set-connection ptcp:6642:0.0.0.0

ovn-nbctl set NB_Global . name=ovn-west
/usr/share/ovn/scripts/ovn-ctl \
    --ovn-ic-nb-db=tcp:10.11.0.6:6645 \
    --ovn-ic-sb-db=tcp:10.11.0.6:6646 \
    start_ic

ovn-nbctl lr-add router
ovn-nbctl lrp-add router router_net1 00:00:02:01:02:03 192.168.2.1/24

ovn-nbctl ls-add net1 
ovn-nbctl lsp-add net1 net1_router \
    -- lsp-set-options net1_router router-port=router_net1 \
    -- lsp-set-type net1_router router \
    -- lsp-set-addresses net1_router router

ovn-nbctl lsp-add net1 vm1
ovn-nbctl lsp-set-addresses vm1 "00:00:02:01:02:0a 192.168.2.2"

ovn-nbctl lsp-add net1 vm2
ovn-nbctl lsp-set-addresses vm2 "00:00:02:01:02:0b 192.168.2.3"

ovn-nbctl lrp-add router lrp-router2-ts1 00:00:02:01:02:0c 169.254.100.2/24
ovn-nbctl lsp-add ts1 lsp-ts1-router2 -- \
    lsp-set-addresses lsp-ts1-router2 router -- \
    lsp-set-type lsp-ts1-router2 router -- \
    lsp-set-options lsp-ts1-router2 router-port=lrp-router2-ts1

ovn-nbctl lrp-set-gateway-chassis lrp-router2-ts1 west-ic-gw1 30
ovn-nbctl lr-route-add router 192.168.1.0/24 169.254.100.1