#!/bin/sh

#  gov.gsa.boottime.sh
#  gov.gsa
#
#  Created by John Graphia on 4/29/18.
#  
# sysctl kern.boottime | awk -F'[= |,]' '{print $6}'| { read boot ; date -j -r "$boot" ; }
#
epoch_time=`cat /Users/jgraphia/Desktop/boot_time.txt|grep BOOT_TIME|awk '{print $7}'`
#
for f in /Users/jgraphia/Desktop/boot_time.txt
do
cat /Users/jgraphia/Desktop/boot_time.txt| awk '{print $7}' "$f"
done
