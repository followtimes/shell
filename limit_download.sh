#!/bin/bash

#类一：15M带宽
tc class add dev eth0 parent 1:0 classid 1:1 cbq bandwidth 15Mbit rate 15Mbit maxburst 20 allot 1514 prio 8 avpkt 1000 cell 8 weight 1Mbit

#类二：10M带宽
tc class add dev eth0 parent 1:1 classid 1:2 cbq bandwidth 15Mbit rate 10Mbit maxburst 20 allot 1514 prio 6 avpkt 1000 cell 8 weight 100Kbit split 1:0
#类三：5M带宽
tc class add dev eth0 parent 1:1 classid 1:3 cbq bandwidth 15Mbit rate 5Mbit maxburst 20 allot 1514 prio 3 avpkt 1000 cell 8 weight 100Kbit split 1:0




#建立过滤器
tc filter add dev eth0 parent 1:0 protocol ip prio 100 route

tc filter add dev eth0 parent 1:0 protocol ip prio 100 route to 2 flowid 1:2
tc filter add dev eth0 parent 1:0 protocol ip prio 100 route to 3 flowid 1:3

#建立路由 10.108.97.236 为eth0 上的本机IP
ip route add 10.106.124.0/24 dev eth0 via 10.108.97.236 realm 2
#ip route add 192.168.1.0/24 dev eth0 via 10.108.97.236 realm 3
