#!/bin/sh

#  gov.gsa.sus.extattrib.sh
#  jss
#
#  Created by John Graphia on 4/30/18.
#
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
#
#
UpdateCount=`$bddy -c "print UpdateCount" $tgt`
# echo $UpdateCount
if [ $UpdateCount -gt 0 ]; then
#echo You have $UpdateCount updates to be installed.
echo "<result>True</result>"
else
#echo You have no updates to be installed.
echo "<result>False</result>"
fi
