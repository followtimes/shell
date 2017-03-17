#!/bin/bash


if [ 0 -eq $# ] 
then
    printf "this command simplify docker operate with buffalo.
    support para as following:
    start:   start buffalo when buffalo is stop
    restart: restart buffalo 
    stop:    stop buffalo when buffalo is running
    id:      show buffalo container id when it is running
    status:  stats buffalo when buffalo is running\n"
else
    arg1=$1
    case $arg1 in
    "start")
        if [ 1 -eq $(docker ps | grep 'buffalo' | wc -l) ]
        then
            echo "buffalo is running"
        else
            echo "docker start buffalo"
            docker start buffalo
        fi
        ;;
    "stop")
        if [ 0 -eq $(docker ps | grep 'buffalo' | wc -l) ]
        then
            echo "buffalo is stop"
        else
            echo "docker stop buffalo"
            docker stop buffalo
        fi
        ;;
    "status")
        if [ 0 -eq $(docker ps | grep 'buffalo' | wc -l) ]
        then
            echo "buffalo is stop, status is meaningless"
            read -p "start buffalo container?(y/n)" answer
            if [ $answer = "y" ]
            then
                echo "docker start buffalo"
                docker start buffalo
                docker stats buffalo
            fi
        else
            echo "docker stats buffalo"
            docker stats buffalo
        fi
        ;;
    "id")
        if [ 0 -eq $(docker ps | grep 'buffalo' | wc -l) ]
        then
            echo "buffalo is stop, i can't get it's container id"
        else
            docker ps | grep "buffalo" | awk '{print $1}'
        fi
        ;;
    "restart")
        if [ 0 -eq $(docker ps | grep 'buffalo' | wc -l) ]
        echo "docker restart buffalo"
        then
            docker start buffalo
        else
            docker restart buffalo
        fi
        ;;
    *)
        echo "illegal para, expected para is:"
        echo "start/restart/stop/status"
    esac
fi
