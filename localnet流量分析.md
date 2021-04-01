localnet流量分析
===


## 拓扑

```
underlay
                                     
                                 ----------- 
                                | ovn-outer |
                                 ----------- 
                                      |eth0     
                                      |     
----------------------------------external--------------------------------
      |eth1                           |eth1           |eth1          |eth1
      |                               |               |              | 
 -----------     ------------    -----------     ----------     -----------
 | ovn-hv1  |   | ovn-ctrl  |   | ovn-hv2   |   | ovn-gw1  |   |  ovn-gw2  | 
 -----------     ------------    -----------     ----------     -----------
      |               |               |               |              |
      |eth0           |eth0           |eth0           |eth0          |eth0 
-------------------------------------------------------------------------- 
                                 10.10.0.0/24

overlay 
         --------------------------  
         |                        |
         |    external-switch     |
         |                        |
         --------------------------
                    |               
                    |10.20.0.100       
                ---------      
                |   R1  |      
                ---------       
        192.168.1.1|  |192.168.2.1   
             ------    ------       
            |                |       
        -----------      -----------    
        | internal|      | internal|    
        | switch1 |      | switch2 |    
        -----------      -----------    
         |   |   |        |   |   |      
        vm1  |  vm3      vm2  |  vm4     
             |                |
             |localnet        |localnet
             |vlan10          |vlan20
        ------------------------------
          |vlan10 |vlan10 |vlan20 |vlan20
          |       |       |       |
         bm1     bm2     bm3     bm4
```
其中:
* vm1(192.168.1.3)和vm2(192.168.2.3)位于ovn-hv1上
* vm3(192.168.1.4)和vm4(192.168.2.4)位于ovn-hv2上
* bm1(192.168.1.5)和bm3(192.168.2.5)位于ovn-outer上


## localnet
在ovn-hv1和ovn-hv2上设置ovn-chassis-mac-mappings

### 虚拟机间东西向流量
* 同logical switch: vm1 ping vm3  流量经localnet

在ovn-hv2 eth1网卡上抓包
```
root@ovn-hv2:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
01:39:04.116630 00:00:01:01:02:0a > 00:00:01:01:02:08, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.3 > 192.168.1.4: ICMP echo request, id 276, seq 1, length 64
01:39:04.117289 00:00:01:01:02:08 > 00:00:01:01:02:0a, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.4 > 192.168.1.3: ICMP echo reply, id 276, seq 1, length 64
```
* 不同logical switch: vm2 ping vm3 流量经localnet，并且包的router mac被修改为设置的chassis mac

在ovn-hv2 eth1上抓包
```
root@ovn-hv2:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
01:41:49.688166 aa:bb:cc:dd:ee:11 > 00:00:01:01:02:08, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.2.3 > 192.168.1.4: ICMP echo request, id 295, seq 1, length 64
01:41:49.688220 aa:bb:cc:dd:ee:22 > 00:00:01:01:02:0b, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.1.4 > 192.168.2.3: ICMP echo reply, id 295, seq 1, length 64
```

### 南北向流量
南北向流量通过tunnel发送，但回复包通过localnet发送

在vm1上ping 8.8.8.8，同时在ovn-hv1 eth0上抓包
```
root@ovn-hv1:/# tcpdump -i eth0 -nn  -e
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
01:50:47.178299 02:42:0a:0a:00:28 > 02:42:0a:0a:00:14, ethertype IPv4 (0x0800), length 156: 10.10.0.40.9806 > 10.10.0.20.6081: Geneve, Flags [C], vni 0x4, proto TEB (0x6558), options [8 bytes]: 00:00:01:01:02:05 > 02:42:0a:af:5a:e1, ethertype IPv4 (0x0800), length 98: 192.168.1.3 > 8.8.8.8: ICMP echo request, id 340, seq 111, length 64
```

在ovn-hv1 eth1网卡上抓包
```
root@ovn-hv1:/# tcpdump -i  eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
01:53:07.491290 00:00:01:01:02:03 > 00:00:01:01:02:0a, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 8.8.8.8 > 192.168.1.3: ICMP echo reply, id 340, seq 251, length 64
```

## reside-on-redirect-chassis

将R1上与internal1 switch相连的lrp的reside-on-redirect-chassis设置为true
将R1上与internal2 switch相连的lrp的reside-on-redirect-chassis设置为true

### 虚拟机间东西向流量

* 同logical switch: vm1 ping vm3  流量经localnet

在ovn-hv2 eth1上抓包
```
root@ovn-hv2:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:06:19.500083 00:00:01:01:02:0a > 00:00:01:01:02:08, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.3 > 192.168.1.4: ICMP echo request, id 179, seq 1, length 64
02:06:19.500781 00:00:01:01:02:08 > 00:00:01:01:02:0a, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.4 > 192.168.1.3: ICMP echo reply, id 179, seq 1, length 64
```

* 不同logical switch：vm2 ping vm3 流量经localnet，但会先将包发送到gateway chassis上进行路由，然后再发送到destination chassis

在ovn-hv1 eth1上抓包
```
root@ovn-hv1:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:13:41.656710 00:00:01:01:02:0b > 00:00:01:01:02:04, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.2.3 > 192.168.1.4: ICMP echo request, id 231, seq 1, length 64
02:13:41.658965 00:00:01:01:02:04 > 00:00:01:01:02:0b, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.1.4 > 192.168.2.3: ICMP echo reply, id 231, seq 1, length 64
```

在ovn-gw1 eth1上抓包
```
root@ovn-gw1:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:13:41.656749 00:00:01:01:02:0b > 00:00:01:01:02:04, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.2.3 > 192.168.1.4: ICMP echo request, id 231, seq 1, length 64
02:13:41.657345 00:00:01:01:02:03 > 00:00:01:01:02:08, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.2.3 > 192.168.1.4: ICMP echo request, id 231, seq 1, length 64
02:13:41.658475 00:00:01:01:02:08 > 00:00:01:01:02:03, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.4 > 192.168.2.3: ICMP echo reply, id 231, seq 1, length 64
02:13:41.658936 00:00:01:01:02:04 > 00:00:01:01:02:0b, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.1.4 > 192.168.2.3: ICMP echo reply, id 231, seq 1, length 64
```

在ovn-hv2 eth1上抓包
```
root@ovn-hv2:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:13:41.657388 00:00:01:01:02:03 > 00:00:01:01:02:08, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.2.3 > 192.168.1.4: ICMP echo request, id 231, seq 1, length 64
02:13:41.658446 00:00:01:01:02:08 > 00:00:01:01:02:03, ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4, 192.168.1.4 > 192.168.2.3: ICMP echo reply, id 231, seq 1, length 64
```

### 南北向流量
南北向流量通过localnet发送给gateway chassis

vm2 ping 8.8.8.8

在ovn-hv1 eth1网卡上抓包
```
root@ovn-hv1:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:17:24.148329 00:00:01:01:02:0b > 00:00:01:01:02:04, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.2.3 > 8.8.8.8: ICMP echo request, id 258, seq 1, length 64
02:17:24.195493 00:00:01:01:02:04 > 00:00:01:01:02:0b, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 8.8.8.8 > 192.168.2.3: ICMP echo reply, id 258, seq 1, length 64
```

在ovn-gw1 eth1上抓包
```
root@ovn-gw1:/# tcpdump -i eth1 -nn -e icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
02:16:56.035988 00:00:01:01:02:0b > 00:00:01:01:02:04, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 192.168.2.3 > 8.8.8.8: ICMP echo request, id 253, seq 1, length 64
02:16:56.036022 00:00:01:01:02:05 > 02:42:9e:ec:27:41, ethertype IPv4 (0x0800), length 98: 10.20.0.100 > 8.8.8.8: ICMP echo request, id 253, seq 1, length 64
02:16:56.120297 02:42:9e:ec:27:41 > 00:00:01:01:02:05, ethertype IPv4 (0x0800), length 98: 8.8.8.8 > 10.20.0.100: ICMP echo reply, id 253, seq 1, length 64
02:16:56.120331 00:00:01:01:02:04 > 00:00:01:01:02:0b, ethertype 802.1Q (0x8100), length 102: vlan 20, p 0, ethertype IPv4, 8.8.8.8 > 192.168.2.3: ICMP echo reply, id 253, seq 1, length 64
```

## redirect-type
将R1上与external-switch相连的lrp的redirect-type设置为bridge

分别在ovn-hv1、ovn-hv2、ovn-gw1和ovn-gw2上设置ovn-chassis-mac-mappings

### 东西向流量
 