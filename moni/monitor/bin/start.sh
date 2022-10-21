#!/bin/sh

chmod 777 main master

nohup ./main > main.log 2>&1 &
echo $!> main.pid

nohup ./master > master.log 2>&1 &
echo $!>master.pid
