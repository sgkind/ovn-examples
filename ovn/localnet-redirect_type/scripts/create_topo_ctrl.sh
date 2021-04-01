#!/bin/bash -x

start-ovn-northd

ovn-nbctl set-connection ptcp:6641:0.0.0.0
ovn-sbctl set-connection ptcp:6642:0.0.0.0

ovn-nbctl ls-add internal1-switch
ovn-nbctl ls-add internal2-switch
ovn-nbctl ls-add transit-switch

ovn-nbctl lr-add R1
ovn-nbctl lrp-add R1 lrp-r1-internal1 00:00:01:01:02:03 192.168.1.1/24 
ovn-nbctl lrp-add R1 lrp-r1-internal2 00:00:01:01:02:04 192.168.2.1/24
ovn-nbctl lrp-add R1 lrp-r1-transit 00:00:01:01:02:05 192.168.3.1/24

ovn-nbctl lsp-add internal1-switch lsp-internal1-r1 \
          -- lsp-set-options lsp-internal1-r1 router-port=lrp-r1-internal1 \
          -- lsp-set-type lsp-internal1-r1 router \
          -- lsp-set-addresses lsp-internal1-r1 router

ovn-nbctl lsp-add internal2-switch lsp-internal2-r1 \
          -- lsp-set-options lsp-internal2-r1 router-port=lrp-r1-internal2 \
          -- lsp-set-type lsp-internal2-r1 router \
          -- lsp-set-addresses lsp-internal2-r1 router

ovn-nbctl lsp-add transit-switch lsp-transit-r1 \
          -- lsp-set-options lsp-transit-r1 router-port=lrp-r1-transit \
          -- lsp-set-type lsp-transit-r1 router \
          -- lsp-set-addresses lsp-transit-r1 router

#ovn-nbctl lrp-set-redirect-type lrp-r1-transit bridged

ovn-nbctl ls-add outside-switch
ovn-nbctl lsp-add outside-switch lsp-external
ovn-nbctl lsp-set-addresses lsp-external unknown
ovn-nbctl lsp-set-type lsp-external localnet
ovn-nbctl lsp-set-options lsp-external network_name=ext

ovn-nbctl lr-add edge
ovn-nbctl lrp-add edge lrp-edge-external 00:00:01:02:01:01 10.20.0.100/24
ovn-nbctl lrp-add edge lrp-edge-transit 00:00:01:02:01:02 192.168.3.254/24

ovn-nbctl lsp-add outside-switch lsp-outside-edge \
          -- lsp-set-options lsp-outside-edge router-port=lrp-edge-external \
          -- lsp-set-type lsp-outside-edge router \
          -- lsp-set-addresses lsp-outside-edge router

ovn-nbctl lsp-add transit-switch lsp-transit-edge \
          -- lsp-set-options lsp-transit-edge router-port=lrp-edge-transit
          -- lsp-set-type lsp-transit-edge router \
          -- lsp-set-addresses lsp-transit-edge router

ovn-nbctl --id=@gc0 create Gateway_Chassis name=external1-port_gw1 \
                                           chassis_name=gw1 \
                                           priority=20 -- \
          --id=@gc1 create Gateway_Chassis name=external1-port_gw2 \
                                           chassis_name=gw2 \
                                           priority=10 -- \
          set Logical_Router_Port lrp-edge-external 'gateway_chassis=[@gc0,@gc1]' 

#ovn-nbctl lr-route-add R1 "0.0.0.0/0" 192.168.3.254
#ovn-nbctl lr-route-add edge "192.168.0.0/16" 192.168.3.1

#ovn-nbctl $OVN_NBDB lr-nat-add edge snat 10.20.0.100 192.168.0.0/16


ovn-nbctl lsp-add internal1-switch vm1
ovn-nbctl lsp-set-addresses vm1 "00:00:01:01:02:0a 192.168.1.3"

ovn-nbctl lsp-add internal2-switch vm2
ovn-nbctl lsp-set-addresses vm2 "00:00:01:01:02:0b 192.168.2.3"

ovn-nbctl lsp-add internal1-switch vm3
ovn-nbctl lsp-set-addresses vm3 "00:00:01:01:02:08 192.168.1.4"

ovn-nbctl lsp-add internal2-switch vm4
ovn-nbctl lsp-set-addresses vm4 "00:00:01:01:02:09 192.168.2.4"

ovn-nbctl lsp-add transit-switch transit-localnet "" 10
ovn-nbctl lsp-set-addresses transit-localnet unknown
ovn-nbctl lsp-set-type transit-localnet localnet
ovn-nbctl lsp-set-options transit-localnet network_name=ext1

ovn-nbctl lsp-add internal1-switch internal1-localnet "" 20
ovn-nbctl lsp-set-addresses internal1-localnet unknown
ovn-nbctl lsp-set-type internal1-localnet localnet
ovn-nbctl lsp-set-options internal1-localnet network_name=ext1

ovn-nbctl lsp-add internal2-switch internal2-localnet "" 30
ovn-nbctl lsp-set-addresses internal2-localnet unknown
ovn-nbctl lsp-set-type internal2-localnet localnet
ovn-nbctl lsp-set-options internal2-localnet network_name=ext1
