#!/bin/bash

intfs=$(/sbin/ifconfig | grep "mtu" | awk '{print $1}') && getTX() { /sbin/ifconfig | grep "TX packets" | awk '{print $5}'; } && tmp1=$(getTX) && sleep 10 && tmp2=$(getTX) && paste -d '\n' <(echo "$tmp1") <(echo "$tmp2") | awk 'NR%2==0{print ($1-p)/10.0}{p=$1}' | paste -d ' ' <(echo "$intfs") -
