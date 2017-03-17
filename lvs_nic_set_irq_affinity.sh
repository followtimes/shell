#!/bin/bash

#turn off irqbalance service 
#centos
chkconfig irqbalance off 2>/dev/null
#ubuntu
update-rc.d -f irqbalance remove 2>/dev/null
#
/etc/init.d/irqbalance stop 2>/dev/null
killall -9 irabalance 2>/dev/null

#
CORES=`grep -c '^processor' /proc/cpuinfo`
NETDEVICES=`awk '{print$2}' /proc/net/dev_mcast |sort|uniq`
IRQS=` for NETDEVICE in $NETDEVICES ;do  grep $NETDEVICE  /proc/interrupts|cut -d: -f1;done`
CORE=0;
MAXCORE=$[$CORES-1];

for IRQ in $IRQS;do 
find /proc/irq/$IRQ -name "smp_affinity" -exec echo -e {} \;
done > irq.tmp

cat /dev/null > setmast.sh
while read irq
 do
   if [ $CORE -ge $MAXCORE ] ;then
	echo "echo `echo 'obase=16;'$[1<<$CORE]|bc`" ">" $irq >>setmast.sh
	CORE=0;
   else
        echo "echo `echo 'obase=16;'$[1<<$CORE]|bc`" ">" $irq >>setmast.sh
        CORE=$[$CORE+1]
   fi
done < irq.tmp
bash -x ./setmast.sh
rm -f irq.tmp setmast.sh
#end
