#!/bin/sh

#  gov.gsa.hotcornerextatrib.sh
#  gov.gsa
#
#  Created by John Graphia on 6/6/18.
#  
liu=`who|grep console|awk '{print $1}'`
#
crnrs=`defaults read /Users/$liu/Library/Preferences/com.apple.dock | grep corner|sed 's/;//'`
#
echo "<result>$crnrs</result>"
