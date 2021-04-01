#!/bin/bash -x

start-ovn-northd

ovn-nbctl set-connection ptcp:6641:0.0.0.0
ovn-sbctl set-connection ptcp:6642:0.0.0.0

ovn-nbctl set NB_Global . name=ovn-east
/usr/share/ovn/scripts/ovn-ctl \
    --ovn-ic-nb-db=tcp:10.11.0.2:6645 \
    --ovn-ic-sb-db=tcp:10.11.0.2:6646 \
    start_ic

ovn-nbctl lr-add lr1
ovn-nbctl lrp-add lr1 lrp_lr1_ls1 00:00:01:01:02:03 192.168.1.1/24

ovn-nbctl ls-add ls1 
ovn-nbctl lsp-add ls1 lsp_ls1_lr1 -- \
    lsp-set-type lsp_ls1_lr1 router -- \
    lsp-set-addresses lsp_ls1_lr1 router -- \
    lsp-set-options lsp_ls1_lr1 router-port=lrp_lr1_ls1

ovn-nbctl lsp-add ls1 vm1
ovn-nbctl lsp-set-addresses vm1 "00:00:01:01:02:0a 192.168.1.2"

ovn-nbctl lrp-add lr1 lrp-lr1-ts1 aa:aa:aa:aa:aa:01 169.254.100.1/24
ovn-nbctl lsp-add ts1 lsp-ts1-lr1 -- \
    lsp-set-type lsp-ts1-lr1 router -- \
    lsp-set-addresses lsp-ts1-lr1 router -- \
    lsp-set-options lsp-ts1-lr1 router-port=lrp-lr1-ts1

ovn-nbctl lrp-set-gateway-chassis lrp-lr1-ts1 east-ic-gw1 30
ovn-nbctl lr-route-add lr1 192.168.2.0/24 169.254.100.2