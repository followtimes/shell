#!/bin/bash

now=$(date +%Y-%m-%d)
d_timestamp=$(date -d $now +%s)
del_time=20

log_dir="$(pwd)/clean_odin_process.log"
echo "" > $log_dir

echo "----------------------------------------------------------------------------" >> $log_dir
echo "now time is : $now timestamp is : $d_timestamp" >> $log_dir
echo "---------------------- start clean odin process -----------------------------" >> $log_dir

cnt=0
for pid in $(ps aux | grep odin  | grep -v grep | awk '{print $2}') 
    do
        if [ -d "/proc/$pid" ]
            then 
            jiffies=$(  cat /proc/$pid/stat | cut -d " " -f22 )
        else
            continue
        fi

        uptime=$(  grep btime /proc/stat | cut -d " " -f2 )
        start_sec=$(( $uptime + $jiffies / $(getconf CLK_TCK )   ))
        
        odin_time=$(date -d "1970-01-01 UTC $start_sec seconds" +%Y-%m-%d)
        odin_timestamp=$(date -d $odin_time +%s)

        dec_time=$(( $(($d_timestamp - $odin_timestamp)) / 86400))

        if [ $dec_time -ge  $del_time  ]

            then

            ((cnt++))
            echo " " >> $log_dir
            echo " " >> $log_dir
            echo "-------------- clean start -----------------" >> $log_dir
            echo "process:" >> $log_dir 
            echo $(ps axu | grep -v grep | grep -w $pid ) >> $log_dir
            echo "pgrep 3 pid:" >> $log_dir
            yml_grep="$(ps axu | grep -v grep | grep -w $pid | awk '{print $14}')"
            if [  -n $yml_grep   ]
                then
                p_pid=$(pgrep -f $yml_grep)
                echo $p_pid >> $log_dir
                pkill -f $yml_grep
            fi
            echo "pid: $pid" >> $log_dir
            echo "start_time: $odin_time"  >> $log_dir
            echo "-------------- clean end -------------------" >> $log_dir

        fi

done

echo "*****************************" >> $log_dir
echo "***clean $cnt odin process***" >> $log_dir
echo "*****************************" >> $log_dir
