#!/bin/bash

###################################################
########### staging operate start #################
###################################################

zk_staging_dir='/home/work/zookeeper_staging/zookeeper-data/version-2'

#backup newtest file every day in sq-jm-stag03.bj
backup_snapshot_staging=/home/work/zookeeper_backup/staging

zk_staging_clean_dir=/home/work/zookeeper_clean_dir/staging

zk_staging_old_log=$zk_staging_clean_dir/old_log
zk_staging_old_snapshot=$zk_staging_clean_dir/old_snapshot

#save newtest file num
save_num=1
#clean old file num
clean_zk_num=7
#clean old backup num
clean_zk_backup_num=30


#create old file dir
if [ ! -d $zk_staging_old_log ]
then
    mkdir  -p $zk_staging_old_log
fi

if [ ! -d $zk_staging_old_snapshot ]
then
    mkdir -p $zk_staging_old_snapshot
fi


log_file_num=$(ls -l  -t $zk_staging_dir/log* | wc -l)
snapshot_file_num=$(ls -l  -t $zk_staging_dir/snapshot* | wc -l)

#mv file to old_dir  except newest file 
if [ $log_file_num  -ge $save_num  ]
then
ls -l  -t $zk_staging_dir/log* | tail -n  $(($( ls -l  -t $zk_staging_dir/log* | wc -l ) - $save_num)) | awk '{print $NF}' |  xargs -i mv {} $zk_staging_old_log
fi
if [ $snapshot_file_num  -ge $save_num  ]
then
ls -l  -t $zk_staging_dir/snapshot* | tail -n  $(($( ls -l  -t $zk_staging_dir/snapshot* | wc -l ) - $save_num)) | awk '{print $NF}' |  xargs -i mv {} $zk_staging_old_snapshot
fi

#clean file which is older than clean_zk_num days
find $zk_staging_old_log/ -mtime +$clean_zk_num | xargs -i rm -f {}
find $zk_staging_old_snapshot/ -mtime +$clean_zk_num | xargs -i rm -f {}

#sq-jm-stag03.bj backup operate
if [ 'sq-jm-stag03.bj' = $(hostname) ]
then 

    #create backup_snapshot_staging dir
    if [ ! -d $backup_snapshot_staging ]
    then
        mkdir -p $backup_snapshot_staging
    fi

    #backup newtest file to backup_snapshot_staging dir
    snapshot_last_file_num=$(ls -l  -t $zk_staging_dir/snapshot* | wc -l)
    if [ $snapshot_last_file_num -ge $save_num ]
    then
    ls -l  -t $zk_staging_dir/snapshot* | head -n  $save_num | awk '{print $NF}' |  xargs -i cp {} $backup_snapshot_staging
    else
    ls -l  -t $zk_staging_dir/snapshot* | head -n  $snapshot_last_file_num | awk '{print $NF}' |  xargs -i cp {} $backup_snapshot_staging
    fi


    #clean file which is older than clean_zk_backup_num days
    find $backup_snapshot_staging/ -mtime +$clean_zk_backup_num | xargs -i rm -f {}
fi
###################################################
########### staging operate end ###################
###################################################

###################################################
########### onebox operate start #################
###################################################

zk_onebox_dir='/home/work/zookeeper_onebox/zookeeper-data/version-2'

#backup newtest file every day in sq-jm-stag03.bj
backup_snapshot_onebox=/home/work/zookeeper_backup/onebox

zk_onebox_clean_dir=/home/work/zookeeper_clean_dir/onebox

zk_onebox_old_log=$zk_onebox_clean_dir/old_log
zk_onebox_old_snapshot=$zk_onebox_clean_dir/old_snapshot


#create old file dir
if [ ! -d $zk_onebox_old_log ]
then
    mkdir  -p $zk_onebox_old_log
fi

if [ ! -d $zk_onebox_old_snapshot ]
then
    mkdir -p $zk_onebox_old_snapshot
fi


log_file_num=$(ls -l  -t $zk_onebox_dir/log* | wc -l)
snapshot_file_num=$(ls -l  -t $zk_onebox_dir/snapshot* | wc -l)

#mv file to old_dir  except newest file 
if [ $log_file_num  -ge $save_num  ]
then
ls -l  -t $zk_onebox_dir/log* | tail -n  $(($( ls -l  -t $zk_onebox_dir/log* | wc -l ) - $save_num)) | awk '{print $NF}' |  xargs -i mv {} $zk_onebox_old_log
fi
if [ $snapshot_file_num  -ge $save_num  ]
then
ls -l  -t $zk_onebox_dir/snapshot* | tail -n  $(($( ls -l  -t $zk_onebox_dir/snapshot* | wc -l ) - $save_num)) | awk '{print $NF}' |  xargs -i mv {} $zk_onebox_old_snapshot
fi

#clean file which is older than clean_zk_num days
find $zk_onebox_old_log/ -mtime +$clean_zk_num | xargs -i rm -f {}
find $zk_onebox_old_snapshot/ -mtime +$clean_zk_num | xargs -i rm -f {}

#sq-jm-stag03.bj backup operate
if [ 'sq-jm-stag03.bj' = $(hostname) ]
then 

    #create backup_snapshot_onebox dir
    if [ ! -d $backup_snapshot_onebox ]
    then
        mkdir -p $backup_snapshot_onebox
    fi

    #backup newtest file to backup_snapshot_onebox dir
    snapshot_last_file_num=$(ls -l  -t $zk_onebox_dir/snapshot* | wc -l)
    if [ $snapshot_last_file_num -ge $save_num ]
    then
    ls -l  -t $zk_onebox_dir/snapshot* | head -n  $save_num | awk '{print $NF}' |  xargs -i cp {} $backup_snapshot_onebox
    else
    ls -l  -t $zk_onebox_dir/snapshot* | head -n  $snapshot_last_file_num | awk '{print $NF}' |  xargs -i cp {} $backup_snapshot_onebox
    fi


    #clean file which is older than clean_zk_backup_num days
    find $backup_snapshot_onebox/ -mtime +$clean_zk_backup_num | xargs -i rm -f {}
fi
###################################################
########### onebox operate end ###################
###################################################

