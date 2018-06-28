#!/bin/sh

#  gov.gsa.sus.extattrib.sh
#  jss
#
#  Created by John Graphia on 4/30/18.
#  Modified JFG 06/28/18
#################################################################
bddy=/usr/libexec/PlistBuddy
#sus=/Library/Preferences/gov.gsa.sus.plist
tgt=/Users/johngraphia/Desktop/SotfwareUpdate.plist
#################################################################
crt=`$bddy -c "print :CriticalUpdateInstall" $tgt`
lrua=`$bddy -c "print :LastRecommendedUpdatesAvailable" $tgt`
lua=`$bddy -c "print :LastUpdatesAvailable" $tgt`
echo echo "<result>Critical $crt Recommended $lrua  Last $lua</result>"
#
exit 0
