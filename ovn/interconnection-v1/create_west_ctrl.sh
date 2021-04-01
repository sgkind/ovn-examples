#!/bin/bash -x

start-ovn-northd

ovn-nbctl set-connection ptcp:6641:0.0.0.0
ovn-sbctl set-connection ptcp:6642:0.0.0.0

ovn-nbctl set NB_Global . name=ovn-west
/usr/share/ovn/scripts/ovn-ctl \
    --ovn-ic-nb-db=tcp:10.11.0.2:6645 \
    --ovn-ic-sb-db=tcp:10.11.0.2:6646 \
    start_ic

ovn-nbctl lr-add lr2
ovn-nbctl lrp-add lr2 lrp_lr2_ls2 00:00:02:01:02:03 192.168.2.1/24

ovn-nbctl ls-add ls2 
ovn-nbctl lsp-add ls2 lsp_ls2_lr2 \
    -- lsp-set-type lsp_ls2_lr2 router \
    -- lsp-set-options lsp_ls2_lr2 router-port=lrp_lr2_ls2 \
    -- lsp-set-addresses lsp_ls2_lr2 router

ovn-nbctl lsp-add ls2 vm1
ovn-nbctl lsp-set-addresses vm1 "00:00:02:01:02:0a 192.168.2.2"

ovn-nbctl lrp-add lr2 lrp-lr2-ts1 00:00:02:01:02:0c 169.254.100.2/24
ovn-nbctl lsp-add ts1 lsp-ts1-lr2 -- \
    lsp-set-type lsp-ts1-lr2 router -- \
    lsp-set-addresses lsp-ts1-lr2 router -- \
    lsp-set-options lsp-ts1-lr2 router-port=lrp-lr2-ts1

ovn-nbctl lrp-set-gateway-chassis lrp-lr2-ts1 west-ic-gw1 30
ovn-nbctl lr-route-add lr2 192.168.1.0/24 169.254.100.1