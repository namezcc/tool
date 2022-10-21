#!/bin/sh

nohup yarn start > web.log 2>&1 &
echo $!>web.pid
echo "start pid $!"
