#!/bin/bash


if [ 0 -eq $# ] 
then
    printf "this command simplify docker operate with nginx.
    support para as following:
    start:   start nginx when nginx is stop
    restart: restart nginx 
    stop:    stop nginx when nginx is running
    id:      show nginx container id when it is running
    status:  stats nginx when nginx is running\n"
else
    arg1=$1
    case $arg1 in
    "start")
        if [ 1 -eq $(docker ps | grep 'nginx' | wc -l) ]
        then
            echo "nginx is running"
        else
            echo "docker start nginx"
            docker start nginx
        fi
        ;;
    "stop")
        if [ 0 -eq $(docker ps | grep 'nginx' | wc -l) ]
        then
            echo "nginx is stop"
        else
            echo "docker stop nginx"
            docker stop nginx
        fi
        ;;
    "status")
        if [ 0 -eq $(docker ps | grep 'nginx' | wc -l) ]
        then
            echo "nginx is stop, status is meaningless"
            read -p "start nginx container?(y/n)" answer
            if [ $answer = "y" ]
            then
                echo "docker start nginx"
                docker start nginx
                docker stats nginx
            fi
        else
            echo "docker stats nginx"
            docker stats nginx
        fi
        ;;
    "id")
        if [ 0 -eq $(docker ps | grep 'nginx' | wc -l) ]
        then
            echo "nginx is stop, i can't get it's container id"
        else
            docker ps | grep "nginx" | awk '{print $1}'
        fi
        ;;
    "restart")
        if [ 0 -eq $(docker ps | grep 'nginx' | wc -l) ]
        echo "docker restart nginx"
        then
            docker start nginx
        else
            docker restart nginx
        fi
        ;;
    *)
        echo "illegal para, expected para is:"
        echo "start/restart/stop/status"
    esac
fi
