## 目标

```
underlay
                                     Internet
                                        |     
                                        |     
              -----------------------external--------------------------
                                                               |          
                                                               |            
              ------------   ------------   ------------  ------------
              |ovn-master|   |ovn-worker1|  |ovn-worker2| |ovn-gateway|
              ------------   ------------   -----------   ------------ 
                    |             |              |             |       
                    |             |              |             |       
              ---------------------------------------------------------
                                   10.10.0.0/24

overlay topo
         --------------------------  
         |                        |
         |      ext_gateway       |
         |                        |
         --------------------------
                    |               
                    |10.20.0.100       
               ------------     
               |GR_gateway|      
               ------------ 
                    |100.64.0.2
                    |
                    |
                    |100.64.0.1
            --------------------
            |ovn-cluster_router|
            --------------------
                   |  |
     10.244.0.1/24 |  |10.244.1.1/24 
             ------    ------       
            |                |       
        -----------      -----------    
        | worker1 |      | worker2 |      
        -----------      -----------    
             |                |          
             |                |
            vm1              vm2 
       100.244.0.2/24   100.244.1.2/24

```
通过peer连接logical router和GR，验证
1. logical switch 间是否正常通信
2. vm是否能通外网
3. floating ip功能是否正常

## run container

```
cd ../lesson/ovn/gateway-router
./start_compose.sh
```

## 如需加载openvswitch内核模块
```bash
sudo modprobe openvswitch
```


## 创建拓扑
```
./setup.sh
```

## 测试
### vm1 ping vm2
```
➜  ~ docker exec -it ovn-worker1 bash
root@ovn-worker1:/# ip netns exec vm1 ping 10.244.1.2 -c 3
PING 10.244.1.2 (10.244.1.2) 56(84) bytes of data.
64 bytes from 10.244.1.2: icmp_seq=1 ttl=63 time=2.06 ms
64 bytes from 10.244.1.2: icmp_seq=2 ttl=63 time=0.208 ms
64 bytes from 10.244.1.2: icmp_seq=3 ttl=63 time=0.163 ms

--- 10.244.1.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2022ms
rtt min/avg/max/mdev = 0.163/0.810/2.060/0.884 ms
root@ovn-worker1:/# exit
exit
```

### vm2 ping vm1
```
➜  ~ docker exec -it ovn-worker2 bash
root@ovn-worker2:/# ip netns exec vm2 ping 10.244.0.2 -c 3
PING 10.244.0.2 (10.244.0.2) 56(84) bytes of data.
64 bytes from 10.244.0.2: icmp_seq=1 ttl=63 time=1.46 ms
64 bytes from 10.244.0.2: icmp_seq=2 ttl=63 time=0.189 ms
64 bytes from 10.244.0.2: icmp_seq=3 ttl=63 time=0.157 ms

--- 10.244.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.157/0.602/1.460/0.606 ms
root@ovn-worker2:/# exit
exit
```

### vm1 ping 8.8.8.8
```
➜  ~ docker exec -it ovn-worker1 bash
root@ovn-worker1:/# ip netns exec vm1 ping 8.8.8.8 -c 3
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=34.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=33.4 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=33.7 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 33.453/33.877/34.477/0.484 ms
root@ovn-worker1:/# exit
exit
```

### vm2 ping 8.8.8.8
```
➜  ~ docker exec -it ovn-worker2 bash
root@ovn-worker2:/# ip netns exec vm2 ping 8.8.8.8 -c 3
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=35.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=33.4 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=33.4 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 33.412/34.201/35.752/1.116 ms
root@ovn-worker2:/# exit
exit
```

### external ping 10.20.0.101（floating ip)
```
➜  ~ ping 10.20.0.101 -c 3
PING 10.20.0.101 (10.20.0.101) 56(84) bytes of data.
64 bytes from 10.20.0.101: icmp_seq=1 ttl=62 time=1.04 ms
64 bytes from 10.20.0.101: icmp_seq=2 ttl=62 time=0.202 ms
64 bytes from 10.20.0.101: icmp_seq=3 ttl=62 time=0.200 ms

--- 10.20.0.101 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2027ms
rtt min/avg/max/mdev = 0.200/0.479/1.037/0.394 ms
```

vm1上抓包
```
root@ovn-worker1:/# ip netns exec vm1 tcpdump -i ens3
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens3, link-type EN10MB (Ethernet), capture size 262144 bytes
06:00:33.492235 IP 10.20.0.1 > 10.244.0.2: ICMP echo request, id 36299, seq 1, length 64
06:00:33.492256 IP 10.244.0.2 > 10.20.0.1: ICMP echo reply, id 36299, seq 1, length 64
06:00:33.496679 IP 10.244.0.2.45261 > 127.0.0.11.domain: 46891+ PTR? 2.0.244.10.in-addr.arpa. (41)
06:00:34.492235 IP 10.20.0.1 > 10.244.0.2: ICMP echo request, id 36299, seq 2, length 64
06:00:34.492257 IP 10.244.0.2 > 10.20.0.1: ICMP echo reply, id 36299, seq 2, length 64
06:00:35.518480 IP 10.20.0.1 > 10.244.0.2: ICMP echo request, id 36299, seq 3, length 64
06:00:35.518502 IP 10.244.0.2 > 10.20.0.1: ICMP echo reply, id 36299, seq 3, length 64
06:00:53.507190 IP 10.244.0.2.53270 > 127.0.0.11.domain: 29019+ PTR? 11.0.0.127.in-addr.arpa. (41)
06:00:58.510368 IP 10.244.0.2.53270 > 127.0.0.11.domain: 29019+ PTR? 11.0.0.127.in-addr.arpa. (41)
```

## 删除测试环境
```bash
./stop_compose.sh
```