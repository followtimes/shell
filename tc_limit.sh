#删除当前ip route 已存在的规则路由
#ip route | grep realm | while read i; do ip route del  $i ; done

#lg-op-xbox03.bj 当前的设备为em1，网关为：10.101.11.254

#建立队列
tc qdisc add dev em1 root handle 1: cbq bandwidth 15Mbit avpkt 1000 cell 8 mpu 64
#建立分类
tc class add dev em1 parent 1:0 classid 1:1 cbq bandwidth 15Mbit rate 15Mbit maxburst 20 allot 1514 prio 8 avpkt 1000 cell 8 weight 1Mbit
tc class add dev em1 parent 1:1 classid 1:2 cbq bandwidth 10Mbit rate 10Mbit maxburst 20 allot 1514 prio 2 avpkt 1000 cell 8 weight 800Kbit split 1:0 bounded
tc class add dev em1 parent 1:1 classid 1:3 cbq bandwidth 5Mbit rate 5Mbit maxburst 20 allot 1514 prio 1 avpkt 1000 cell 8 weight 800Kbit split 1:0 bounded
#建立过滤器
tc filter add dev em1 parent 1:0 protocol ip prio 100 route
tc filter add dev em1 parent 1:0 protocol ip prio 100 route to 2 flowid 1:2
tc filter add dev em1 parent 1:0 protocol ip prio 100 route to 3 flowid 1:3
#建立路由
#ip route add 10.106.124.16/32 dev em1 via 10.101.11.254 realm 2
#新加坡限速
ip route add 10.64.0.0/16  via 10.101.11.254 dev em1 realm 2 
ip route add 10.68.0.0/16  via 10.101.11.254 dev em1 realm 2 
ip route add 10.60.0.0/16  via 10.101.11.254 dev em1 realm 2 
ip route add 10.72.16.0/20 via 10.101.11.254 dev em1 realm 2 

#美西限速
ip route add 10.66.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.67.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.61.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.71.0.0/20 via 10.101.11.254 dev em1 realm 3 
ip route add 10.69.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.65.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.70.0.0/16 via 10.101.11.254 dev em1 realm 3 
ip route add 10.72.0.0/20 via 10.101.11.254 dev em1 realm 3 
