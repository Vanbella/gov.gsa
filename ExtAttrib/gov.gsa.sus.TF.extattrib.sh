#!/bin/sh
#  gov.gsa.sus.extattrib.sh
#  jss
#
#  Created by John Graphia on 4/30/18.
#  Modified JFG 06/28/18
#################################################################
bddy=/usr/libexec/PlistBuddy
#sus=/Library/Preferences/gov.gsa.sus.plist
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
#################################################################
crt=`$bddy -c "print :CriticalUpdateInstall" $tgt`
lrua=`$bddy -c "print :LastRecommendedUpdatesAvailable" $tgt`
#lua=`$bddy -c "print :LastUpdatesAvailable" $tgt`
updcnt=$(($crt+lrua))
if [ $updcnt -gt 0 ]; then
#
echo echo "<result>True</result>"
#
else
echo echo "<result>False</result>"
fi
exit 0
