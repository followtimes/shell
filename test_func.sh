#!/bin/bash

main(){
    echo "$# para is pass in"
    echo "there is: $@"
    for i in $@
    do
        echo $i
    done
    echo "there is: $*"
    for i in $*
    do
        echo $i
    done
}


main $@
