#!/bin/sh
function stop()
{
        kill -15 $1

        sleep_num=1
        while true
        do
                num=$(ps -p $1 | wc -l)

                if [ "$num" -lt "2" ]
                then
                        break
                elif [ "$sleep_num" -gt "5" ]
                then
                        kill -9 $1
                        break
                fi

                sleep_num=$(($sleep_num+1))
                sleep 1
        done
}

stop `cat main.pid`
stop `cat master.pid`
