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
- 通过peer连接logical router和GR，验证GR功能是否正常

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
# docker exec -it ovn-worker1 bash
root@ovn-worker1:/# ip netns exec vm1 ping 10.244.1.2 -c 3
PING 10.244.1.2 (10.244.1.2) 56(84) bytes of data.
64 bytes from 10.244.1.2: icmp_seq=1 ttl=63 time=0.192 ms
64 bytes from 10.244.1.2: icmp_seq=2 ttl=63 time=0.154 ms
64 bytes from 10.244.1.2: icmp_seq=3 ttl=63 time=0.155 ms

--- 10.244.1.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.154/0.167/0.192/0.017 ms
```

### vm2 ping vm1
```
# docker exec -it ovn-worker2 bash
root@ovn-worker2:/# ip netns exec vm2 ping 10.244.0.2 -c 3
PING 10.244.0.2 (10.244.0.2) 56(84) bytes of data.
64 bytes from 10.244.0.2: icmp_seq=1 ttl=63 time=0.200 ms
64 bytes from 10.244.0.2: icmp_seq=2 ttl=63 time=0.087 ms
64 bytes from 10.244.0.2: icmp_seq=3 ttl=63 time=0.198 ms

--- 10.244.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.087/0.161/0.200/0.054 ms
```

### vm1 ping 8.8.8.8
```
# docker exec -it ovn-worker1 bash
root@ovn-worker1:/# ip netns exec vm1 ping 8.8.8.8 -c 3
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=39.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=34.0 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=33.6 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 33.604/35.659/39.289/2.578 ms
```

### vm2 ping 8.8.8.8
```
root@ovn-worker2:/# ip netns exec vm2 ping 8.8.8.8 -c 3 
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=34.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=33.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=111 time=32.7 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 32.758/33.711/34.787/0.859 ms
```