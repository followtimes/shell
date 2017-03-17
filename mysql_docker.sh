#!/bin/bash


if [ 0 -eq $# ] 
then
    printf "this command simplify docker operate with test_mysql.
    support para as following:
    start:   start test_mysql when test_mysql is stop
    restart: restart test_mysql 
    stop:    stop test_mysql when test_mysql is running
    id:      show test_mysql container id when it is running
    status:  stats test_mysql when test_mysql is running\n"
else
    arg1=$1
    case $arg1 in
    "start")
        if [ 1 -eq $(docker ps | grep 'test_mysql' | wc -l) ]
        then
            echo "test_mysql is running"
        else
            echo "docker start test_mysql"
            docker start test_mysql
        fi
        ;;
    "stop")
        if [ 0 -eq $(docker ps | grep 'test_mysql' | wc -l) ]
        then
            echo "test_mysql is stop"
        else
            echo "docker stop test_mysql"
            docker stop test_mysql
        fi
        ;;
    "status")
        if [ 0 -eq $(docker ps | grep 'test_mysql' | wc -l) ]
        then
            echo "test_mysql is stop, status is meaningless"
            read -p "start test_mysql container?(y/n)" answer
            if [ $answer = "y" ]
            then
                echo "docker start test_mysql"
                docker start test_mysql
                docker stats test_mysql
            fi
        else
            echo "docker stats test_mysql"
            docker stats test_mysql
        fi
        ;;
    "id")
        if [ 0 -eq $(docker ps | grep 'test_mysql' | wc -l) ]
        then
            echo "test_mysql is stop, i can't get it's container id"
        else
            docker ps | grep "test_mysql" | awk '{print $1}'
        fi
        ;;
    "restart")
        if [ 0 -eq $(docker ps | grep 'test_mysql' | wc -l) ]
        echo "docker restart test_mysql"
        then
            docker start test_mysql
        else
            docker restart test_mysql
        fi
        ;;
    *)
        echo "illegal para, expected para is:"
        echo "start/restart/stop/status"
    esac
fi
