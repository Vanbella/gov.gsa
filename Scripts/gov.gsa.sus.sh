#!/bin/bash
#
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
#
# Cleanup from previous Day
##############################
$bddy -c "delete Updates" $tgt &> /dev/null
$bddy -c "add Updates array " $tgt &> /dev/null
$bddy -c "delete UpdateCount" $tgt &> /dev/null
##############################
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
if [ $dfrcnt -gt 0 ]; then
echo "defer in process"
else
#$bddy -c "delete DeferDays" $tgt &> /dev/null
$bddy -c "add DeferDays integer 8 " $tgt &> /dev/null
# Give the user 8 days to defer update installs
#$bddy -c "delete DeferCount" $tgt &> /dev/null
$bddy -c "add DeferCount integer 0 " $tgt &> /dev/null
# Count how many times the user defers
fi
#
for lst in $(softwareupdate -l|sed -e '1,4 d' -e '/*/d' -e 's/ //g')
do
$bddy -c "add Updates:0 string "$lst"" $tgt &> /dev/null
#
done
#
UpdCnt=`defaults read /Library/Preferences/gov.gsa.sus Updates|sed -e 's/(//g' -e 's/)//g' -e '/^$/d'|wc -l`
#
#
$bddy -c "add UpdateCount integer '$UpdCnt' " $tgt &> /dev/null
#
exit 0
