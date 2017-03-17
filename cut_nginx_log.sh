#!/bin/bash
# This script run at 00:00
# 01 00 * * * /bin/bash  /home/work/opshell/cut_nginx_log.sh

# Set variable
logs_path="/home/work/log/nginx"
old_logs_path="/home/work/log/nginx/old"
nginx_pid="/home/work/nginx/logs/nginx.pid"

time_stamp=`date -d "yesterday" +%Y-%m-%d`

mkdir -p ${old_logs_path}
# Main
cd $logs_path
for file in `find ./ -maxdepth 1 -type f | sed 's/^\.\///g' | grep -v '^nginx.pid$'`
do
    if [ ! -f ${old_logs_path}/${time_stamp}_$file ]
    then
        dst_file="${old_logs_path}/${time_stamp}_$file"
    else
        dst_file="${old_logs_path}/${time_stamp}_$file.$$"
    fi
    mv $file $dst_file
done

chown -R work.work $logs_path/*

kill -USR1 `cat $nginx_pid`

