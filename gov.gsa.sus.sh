#!/bin/bash
#
bddy=/usr/libexec/PlistBuddy
sus=/Library/Preferences/gov.gsa.sus.plist
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
#
# Cleanup
##############################
$bddy -c "delete Updates array " $sus &> /dev/null
$bddy -c "delete Updates" $sus &> /dev/null
#$bddy -c "delete UpdateCount" $sus &> /dev/null
##############################
#dfrcnt=`$bddy -c "print :DeferCount" $sus`
#if [[ $dfrcnt -gt 0 ]]; then
#echo "defer in process"
#else
#$bddy -c "delete DeferDays" $sus &> /dev/null
$bddy -c "add DeferDays integer 8 " $sus &> /dev/null
# Give the user 8 days to defer update installs
#$bddy -c "delete DeferCount" $sus &> /dev/null
$bddy -c "add DeferCount integer 0 " $sus &> /dev/null
# Count how many times the user defers
#fi
# List the updates and write them to an array
# superceded by com.apple.SoftwareUpdate.plist
#for lst in $(softwareupdate -l|sed -e '1,4 d' -e '/*/d' -e 's/ //g')
#do
#$bddy -c "add Updates:0 string "$lst"" $tgt &> /dev/null
#done
#lrua=`defaults read $tgt LastRecommendedUpdatesAvailable`
#lua=`defaults read $tgt LastUpdatesAvailable`
#$bddy -c "add LastRecommendedUpdatesAvailable integer '$lrua' " $sus &> /dev/null
#$bddy -c "add LastUpdatesAvailable integer '$lua' " $sus &> /dev/null

exit 0
