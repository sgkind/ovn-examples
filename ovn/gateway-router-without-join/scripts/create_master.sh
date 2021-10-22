#!/bin/bash -x

start-ovn-northd

ovn-nbctl set-connection ptcp:6641:0.0.0.0
ovn-sbctl set-connection ptcp:6642:0.0.0.0

ovn-nbctl lr-add GR_gateway
ovn-nbctl lr-add ovn_cluster_router

ovn-nbctl ls-add join
ovn-nbctl ls-add worker1
ovn-nbctl ls-add worker2
ovn-nbctl ls-add ext_gateway

# add ports to ext_gateway
ovn-nbctl lsp-add ext_gateway breth1
ovn-nbctl lsp-set-addresses breth1 unknown
ovn-nbctl lsp-set-type breth1 localnet
ovn-nbctl lsp-set-options breth1 network_name=ext
ovn-nbctl lsp-add ext_gateway etor-GR_gateway \
    -- lsp-set-type etor-GR_gateway router \
    -- lsp-set-addresses etor-GR_gateway router \
    -- lsp-set-options etor-GR_gateway router-port=rtoe-GR_gateway

# add ports to GR_gateway
ovn-nbctl lrp-add GR_gateway rtoe-GR_gateway 0a:58:0a:a4:00:64 10.20.0.100/24
ovn-nbctl lrp-add GR_gateway rtoj-GR_gateway 0a:58:64:40:00:02 100.64.0.2/16 peer=rtoj-ovn_cluster_router

# add ports to ovn_cluster_router
ovn-nbctl lrp-add ovn_cluster_router rtoj-ovn_cluster_router 0a:58:64:40:00:01 100.64.0.1/16 peer=rtoj-GR_gateway
ovn-nbctl lrp-add ovn_cluster_router rtoj-worker1 0a:58:0a:f4:00:01 10.244.0.1/24
ovn-nbctl lrp-add ovn_cluster_router rtoj-worker2 0a:58:0a:f4:01:01 10.244.1.1/24

# add port to worker1
ovn-nbctl lsp-add worker1 stor-worker1 \
    -- lsp-set-type stor-worker1 router \
    -- lsp-set-addresses stor-worker1 router \
    -- lsp-set-options stor-worker1 router-port=rtoj-worker1
ovn-nbctl lsp-add worker1 default-vm1
ovn-nbctl lsp-set-addresses default-vm1 "0a:58:0a:f4:00:02 10.244.0.2/24"

# add port to worker2
ovn-nbctl lsp-add worker2 stor-worker2 \
    -- lsp-set-type stor-worker2 router \
    -- lsp-set-addresses stor-worker2 router \
    -- lsp-set-options stor-worker2 router-port=rtoj-worker2
ovn-nbctl lsp-add worker2 default-vm2
ovn-nbctl lsp-set-addresses default-vm2 "0a:58:0a:f4:01:02 10.244.1.2/24"

ovn-nbctl lrp-set-gateway-chassis rtoe-GR_gateway gateway 1

ovn-nbctl --policy=src-ip lr-route-add ovn_cluster_router 10.244.0.0/24 100.64.0.2
ovn-nbctl --policy=src-ip lr-route-add ovn_cluster_router 10.244.1.0/24 100.64.0.2

ovn-nbctl lr-nat-add GR_gateway snat 10.20.0.100 10.244.0.0/16
ovn-nbctl lr-nat-add GR_gateway dnat_and_snat 10.20.0.101 10.244.0.2
ovn-nbctl --policy=dst-ip lr-route-add GR_gateway 10.244.0.0/16 100.64.0.1
ovn-nbctl lr-route-add GR_gateway 0.0.0.0/0 10.20.0.1
