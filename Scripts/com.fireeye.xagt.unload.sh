#!/bin/sh

#  com.fireeye.xagt.unload.sh
#  gov.gsa
#
#  Created by John Graphia on 5/7/18.
liu=`who|grep console|awk '{print $1}'`
#  
launchctl unload /Library/LaunchDaemons/com.fireeye.xagt.plist
sudo -u $liu launchctl unload /Library/LaunchAgents/com.fireeye.xagtnotif.plist
#
exit 0
