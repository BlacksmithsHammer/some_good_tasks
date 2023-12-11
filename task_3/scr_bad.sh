#!/bin/bash

/sbin/ifconfig | grep "TX packets" | awk '{print $5}' >tmp1 && sleep 10 && /sbin/ifconfig | grep "TX packets" | awk '{print $5}'> tmp2 && paste -d \\n tmp1 tmp2 | awk 'NR%2==0{print ($1-p)/10.0}{p=$1}'
